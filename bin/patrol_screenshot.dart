import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String version = '0.1.0';

void main(List<String> arguments) async {
  String device = 'chrome';
  String outBase = 'test_results';
  String? testFile;
  bool verbose = false;

  // Parse arguments
  int i = 0;
  while (i < arguments.length) {
    switch (arguments[i]) {
      case '--device':
        if (i + 1 >= arguments.length) {
          stderr.writeln('Error: --device requires a value');
          exit(1);
        }
        device = arguments[++i];
        break;
      case '--output-dir':
        if (i + 1 >= arguments.length) {
          stderr.writeln('Error: --output-dir requires a value');
          exit(1);
        }
        outBase = arguments[++i];
        break;
      case '--verbose':
      case '-v':
        verbose = true;
        break;
      case '--help':
      case '-h':
        _printUsage();
        exit(0);
      default:
        if (arguments[i].startsWith('-')) {
          stderr.writeln('Error: Unknown option: ${arguments[i]}');
          _printUsage();
          exit(1);
        }
        testFile = arguments[i];
    }
    i++;
  }

  if (testFile == null || testFile.isEmpty) {
    stderr.writeln('Error: No test file specified.\n');
    _printUsage();
    exit(1);
  }

  // Setup output directory
  final outDir = Directory(outBase);
  try {
    await outDir.create(recursive: true);
  } catch (e) {
    stderr.writeln('Error: Could not create output directory: $e');
    exit(1);
  }

  int nextId = 1;
  try {
    final entries = outDir.listSync();
    int maxId = 0;
    for (final entry in entries) {
      if (entry is Directory) {
        final name = entry.path.split('/').last;
        if (name.startsWith('run_')) {
          final idStr = name.substring(4);
          final id = int.tryParse(idStr);
          if (id != null && id > maxId) {
            maxId = id;
          }
        }
      }
    }
    nextId = maxId + 1;
  } catch (e) {
    // If error reading directory, just use 1
    nextId = 1;
  }

  final screenshotDirPath = '$outBase/run_$nextId/screenshots';

  print('======================================================');
  print('  patrol-screenshot v$version');
  print('  Test run #$nextId');
  print('  Target:      $testFile');
  print('  Device:      $device');
  print('  Screenshots: $screenshotDirPath');
  print('======================================================');

  final startTime = DateTime.now();
  int screenshotCount = 0;

  try {
    final args = [
      'test',
      '--target', testFile,
      '--device', device,
      '--show-flutter-logs',
      if (verbose) '--verbose',
    ];
    if (verbose) {
      stderr.writeln('[debug] Running: patrol ${args.join(' ')}');
      stderr.writeln('[debug] Working directory: ${Directory.current.path}');
    }

    final process = await Process.start('patrol', args);

    // Forward stderr directly so nothing is swallowed
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => stderr.writeln(verbose ? '[patrol stderr] $line' : line));

    final lines = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final spinnerController = _SpinnerController();
    Map<String, StringBuffer> pendingScreenshots = {};

    await for (final line in lines) {
      if (verbose) stderr.writeln('[patrol stdout raw] $line');
      // Check for screenshot protocol markers
      if (line.contains('[[PATROL_SCREENSHOT_START|')) {
        final payload = _extractPayload(line, 'PATROL_SCREENSHOT_START');
        if (payload != null) {
          pendingScreenshots[payload] = StringBuffer();
          spinnerController.start('Capturing screenshot: $payload');
        }
      } else if (line.contains('[[PATROL_SCREENSHOT_CHUNK|')) {
        final match = _extractChunk(line);
        if (match != null) {
          final (name, chunk) = match;
          if (pendingScreenshots.containsKey(name)) {
            // Filter to valid base64 characters
            final filtered =
                chunk.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
            pendingScreenshots[name]!.write(filtered);
          }
        }
      } else if (line.contains('[[PATROL_SCREENSHOT_END|')) {
        final payload = _extractPayload(line, 'PATROL_SCREENSHOT_END');
        if (payload != null && pendingScreenshots.containsKey(payload)) {
          spinnerController.stop();
          await _decodeAndSaveScreenshot(
            payload,
            pendingScreenshots[payload]!.toString(),
            screenshotDirPath,
          );
          pendingScreenshots.remove(payload);
          screenshotCount++;
        }
      } else if (!line.contains('[[PATROL_SCREENSHOT_')) {
        // Print lines that are not screenshot protocol
        print(line);
      }
    }

    spinnerController.stop();
    final exitCode = await process.exitCode;
    if (verbose) stderr.writeln('[debug] patrol exit code: $exitCode');
    if (exitCode != 0) {
      exit(exitCode);
    }
  } catch (e) {
    stderr.writeln('Error: Failed to run patrol: $e');
    exit(1);
  }

  final endTime = DateTime.now();
  final duration = endTime.difference(startTime).inSeconds;

  print('');
  print('======================================================');
  print('  Done. $screenshotCount screenshot(s) saved to $screenshotDirPath');
  print('  Duration: ${duration}s');
  print('======================================================');
}

void _printUsage() {
  print('patrol-screenshot v$version — Screenshot capture for Patrol integration tests');
  print('');
  print('Usage:');
  print('  patrol-screenshot <test_file> [options]');
  print('');
  print('Options:');
  print('  --device <device>      Target device (default: chrome)');
  print('  --output-dir <path>    Base output directory (default: test_results)');
  print('  --verbose, -v          Enable verbose debug output');
  print('  --help                 Show this help message');
  print('');
  print('Examples:');
  print('  patrol-screenshot integration_test/main_test.dart');
  print('  patrol-screenshot integration_test/main_test.dart --device chrome');
  print('  patrol-screenshot integration_test/main_test.dart --output-dir ./screenshots');
}

String? _extractPayload(String line, String markerType) {
  final startMarker = '[[${markerType}|';
  final startIdx = line.indexOf(startMarker);
  if (startIdx == -1) return null;

  final contentStart = startIdx + startMarker.length;
  final endIdx = line.indexOf(']]', contentStart);
  if (endIdx == -1) return null;

  return line.substring(contentStart, endIdx);
}

(String, String)? _extractChunk(String line) {
  const markerStart = '[[PATROL_SCREENSHOT_CHUNK|';
  final idx = line.indexOf(markerStart);
  if (idx == -1) return null;

  final contentStart = idx + markerStart.length;
  final endIdx = line.indexOf(']]', contentStart);
  if (endIdx == -1) return null;

  final content = line.substring(contentStart, endIdx);
  final pipeIdx = content.indexOf('|');
  if (pipeIdx == -1) return null;

  final name = content.substring(0, pipeIdx);
  final chunk = content.substring(pipeIdx + 1);
  return (name, chunk);
}

Future<void> _decodeAndSaveScreenshot(
  String name,
  String base64String,
  String outDir,
) async {
  final pngPath = '$outDir/$name.png';

  try {
    await Directory(outDir).create(recursive: true);
    final bytes = base64Decode(base64String);
    final file = File(pngPath);
    await file.writeAsBytes(bytes);

    if (await file.length() > 0) {
      print('  -> Saved: $pngPath');
    } else {
      print('  -> FAILED: $pngPath (0 bytes)');
    }
  } catch (e) {
    print('  -> FAILED: $pngPath ($e)');
  }
}

class _SpinnerController {
  static const List<String> frames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏'
  ];

  Timer? _timer;
  int _frameIndex = 0;
  String _label = '';

  void start(String label) {
    stop();
    _label = label;
    _frameIndex = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      stdout.write(
        '\r  ${frames[_frameIndex]}  $_label ',
      );
      _frameIndex = (_frameIndex + 1) % frames.length;
    });
  }

  void stop() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      stdout.write('\r\x1b[2K'); // Clear line
    }
  }
}

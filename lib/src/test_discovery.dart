import 'dart:io';
import 'models/test_file.dart';

/// Test discovery engine that scans for Dart test files
class TestDiscoveryEngine {
  /// Scan directory for test files matching pattern *_test.dart
  static Future<List<TestFile>> scan(String baseDir) async {
    final tests = <TestFile>[];
    final dir = Directory(baseDir);

    // Ensure directory exists
    if (!await dir.exists()) {
      return tests;
    }

    try {
      // Recursively list all entities in the directory
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('_test.dart')) {
          final test = _parseTestFile(entity);
          if (test != null) {
            tests.add(test);
          }
        }
      }
    } catch (e) {
      // Silently ignore errors (permissions, etc.)
    }

    // Sort by name for consistent ordering
    tests.sort((a, b) => a.name.compareTo(b.name));
    return tests;
  }

  /// Parse a test file and extract metadata
  static TestFile? _parseTestFile(File file) {
    try {
      final content = file.readAsStringSync();
      final name = _extractTestName(content, file.path);
      final testCases = _extractTestCases(content);

      return TestFile(
        path: file.path,
        name: name,
        description: _extractDescription(content),
        lastModified: file.lastModifiedSync(),
        testCases: testCases,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract main test name from file content or path
  static String _extractTestName(String content, String path) {
    // Try to extract from main() function first
    final mainMatch =
        RegExp(r'void\s+main\s*\(\s*\)\s*\{').firstMatch(content);
    if (mainMatch != null) {
      // Look for group() call
      final groupPattern = RegExp(r'''group\s*\(\s*['"]([^'"]+)['"]''');
      final groupMatch = groupPattern.firstMatch(content);
      if (groupMatch != null) {
        return groupMatch.group(1) ?? path.split('/').last;
      }
    }

    // Fall back to filename without extension
    final filename = path.split('/').last.replaceAll('_test.dart', '');
    return filename
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Extract description from file header comments
  static String _extractDescription(String content) {
    final lines = content.split('\n');
    final buffer = <String>[];

    for (final line in lines) {
      if (line.trim().startsWith('//')) {
        buffer.add(line.trim().replaceFirst('//', '').trim());
      } else if (line.trim().startsWith('/*')) {
        buffer.add(line.trim().replaceFirst('/*', '').replaceFirst('*/', '').trim());
        break;
      } else if (buffer.isNotEmpty) {
        break;
      }
    }

    return buffer.join(' ').trim();
  }

  /// Extract individual test cases from file
  static List<TestCase> _extractTestCases(String content) {
    final cases = <TestCase>[];
    final lines = content.split('\n');
    final testPattern = RegExp(r'''testWidgets\s*\(\s*['"]([^'"]+)['"]''');
    final testSimplePattern = RegExp(r'''test\s*\(\s*['"]([^'"]+)['"]''');

    for (var i = 0; i < lines.length; i++) {
      var match = testPattern.firstMatch(lines[i]);
      match ??= testSimplePattern.firstMatch(lines[i]);

      if (match != null) {
        cases.add(
          TestCase(
            name: match.group(1) ?? 'Unknown',
            lineNumber: i + 1,
          ),
        );
      }
    }

    return cases;
  }
}

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:screenshot/screenshot.dart';

final _controller = ScreenshotController();
int _counter = 0;

/// Wrap your app widget to enable screenshots.
/// Usage: `await $.pumpWidgetAndSettle(screenshotWrapper(const MyApp()));`
Widget screenshotWrapper(Widget child) {
  return Screenshot(controller: _controller, child: child);
}

/// Take a screenshot with auto-incrementing number prefix.
/// Produces files like `1-login_empty.png`, `2-dashboard.png`, etc.
Future<void> takeScreenshot(String name) async {
  _counter++;
  final bytes = await _controller.capture(pixelRatio: 3.0);
  if (bytes != null) {
    _logForBash('$_counter-$name', bytes);
  }
}

void _logForBash(String name, List<int> bytes) {
  final base64String = base64Encode(bytes);

  print('[[PATROL_SCREENSHOT_START|$name]]');

  const chunkSize = 100;
  for (var i = 0; i < base64String.length; i += chunkSize) {
    final end = (i + chunkSize < base64String.length)
        ? i + chunkSize
        : base64String.length;
    print(
      '[[PATROL_SCREENSHOT_CHUNK|$name|${base64String.substring(i, end)}]]',
    );
  }

  print('[[PATROL_SCREENSHOT_END|$name]]');
}

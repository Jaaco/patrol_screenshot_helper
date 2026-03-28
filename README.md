# patrol_screenshot_helper

A lightweight Flutter helper package for capturing screenshots in Patrol integration tests. Provides simple functions to wrap widgets and capture screenshots with auto-incrementing filenames.

## Features

- **Simple widget wrapping** - Wrap your app with `screenshotWrapper()` to enable screenshot capture
- **Auto-incrementing filenames** - Screenshots are automatically numbered (1-login.png, 2-dashboard.png, etc.)
- **High-quality captures** - Captures at 3x pixel ratio for crisp images
- **Bash-friendly output** - Uses structured print statements for easy parsing in test scripts

## Installation

Add this to your `pubspec.yaml`:

```yaml
dev_dependencies:
  patrol_screenshot_helper: ^0.1.0
```

## Usage

Wrap your app widget with `screenshotWrapper()`:

```dart
import 'package:patrol_screenshot_helper/patrol_screenshot_helper.dart';

await $.pumpWidgetAndSettle(
  screenshotWrapper(const MyApp()),
);
```

Then take screenshots with auto-incrementing numbers:

```dart
await takeScreenshot('login_empty');      // Produces: 1-login_empty.png
await takeScreenshot('dashboard');        // Produces: 2-dashboard.png
await takeScreenshot('user_profile');     // Produces: 3-user_profile.png
```

## How it works

The package wraps the Flutter `screenshot` package and provides:

1. **screenshotWrapper()** - Wraps your widget tree with the Screenshot controller
2. **takeScreenshot()** - Captures the screen and outputs base64-encoded bytes via structured print statements

The output format is designed to be parsed by test runners:
```
[[PATROL_SCREENSHOT_START|<name>]]
[[PATROL_SCREENSHOT_CHUNK|<name>|<base64_chunk>]]
...
[[PATROL_SCREENSHOT_END|<name>]]
```

## Dependencies

- `flutter` - Flutter SDK (>=3.0.0)
- `screenshot` - Screenshot capture plugin (^2.0.0)

## License

MIT

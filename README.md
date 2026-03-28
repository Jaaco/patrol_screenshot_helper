# patrol_screenshot_helper

A comprehensive solution for managing Patrol integration tests: a lightweight Flutter helper package for widget screenshot capture, plus a terminal UI for discovering and managing tests.

**This repository contains:**
- **patrol_screenshot_helper** (main package) — Flutter widget wrapper and screenshot utilities
- **patrol_screenshot_cli** (subdirectory) — Dart-only CLI tool for global installation (no Flutter dependency)

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

## Nocterm Terminal UI

Discover and manage your patrol tests with an interactive terminal UI. Install globally like `patrol` to use across all projects.

### Installation (Global)

Install the CLI globally from Git:

```bash
dart pub global activate --source git https://github.com/Jaaco/patrol_screenshot_helper.git --git-path patrol_screenshot_cli
```

Ensure `~/.pub-cache/bin` is in your PATH:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Quick Start

After global installation, launch from any project directory:

```bash
patrol-screenshot-ui
```

The command automatically scans the `./integration-test/` directory for patrol tests.

### Development: Run Locally

To run the CLI without global installation:

```bash
cd patrol_screenshot_cli
dart pub get
dart bin/patrol_screenshot_ui.dart
```

### Features

- **Test Discovery** - Automatically scans `./integration-test/` for all `*_test.dart` files
- **Real-time Search** - Filter tests by name, path, or description as you type
- **Test Details** - View full metadata for each test (path, description, test cases, last modified)
- **Keyboard Navigation** - Arrow keys to navigate, Enter to run, q to quit
- **Test Case Listing** - See individual test cases within each test file

### How to Use

1. **Navigate Tests**: Use `↑` and `↓` arrow keys to move through the test list
2. **Search**: Press `/` or `Ctrl+F` to focus the search bar, then type to filter
3. **View Details**: Select a test to see its full details in the right panel
4. **Run Test**: Press `Enter` on a selected test (feature in development)
5. **Quit**: Press `q` or `Ctrl+C` to exit

### Example Session

```
┌──────────────────────────────────────────────────────────────┐
│ ▶ Patrol Screenshot Helper - Test Runner (v0.2.0)           │
├──────────────────────────────────────────────────────────────┤
│ Search: [_________________] (Type to filter)                 │
├─────────────────────────────┬────────────────────────────────┤
│  Found Tests (12)           │ Details                         │
├─────────────────────────────┼────────────────────────────────┤
│ > app_initial_state         │ Path:                           │
│   auth_login                │   integration-test/app_test     │
│   dashboard_widget          │ Description:                    │
│   profile_avatar_display    │   Verifies app initializes      │
│   settings_form             │   without crashes               │
│   ...                       │                                 │
│                             │ Test Cases: 1                   │
├─────────────────────────────┴────────────────────────────────┤
│ [▶ Run] [Cancel] | Idle | ↑↓: Select | Enter: Run | q: Quit │
└──────────────────────────────────────────────────────────────┘
```

### Requirements

- **Dart SDK**: >=3.0.0
- **CLI Package**: Dart-only, no Flutter dependency required for global use
- **TUI Library**: nocterm ^0.1.0, riverpod ^2.4.0 (managed by patrol_screenshot_cli)

### Troubleshooting

**Command not found after installation**
- Verify `~/.pub-cache/bin` is in your PATH: `echo $PATH | grep pub-cache`
- Add to your shell profile: `export PATH="$PATH:$HOME/.pub-cache/bin"`
- Reload shell: `source ~/.bashrc` (or `~/.zshrc` for zsh)

**"No tests found"**
- Ensure test files are in the `./integration-test/` directory
- Test files must follow the naming pattern `*_test.dart`
- Run from project root where `integration-test/` exists

**Dependencies resolve to incompatible versions**
- Update Dart SDK: `dart upgrade`
- Clear pub cache: `dart pub cache clean`
- Reinstall: `dart pub global activate --source git <repo> --git-path patrol_screenshot_cli`

**Application crashes on startup**
- Ensure your terminal supports ANSI escape codes (most modern terminals do)
- Try a different terminal emulator if issues persist
- Check Dart version: `dart --version` (requires >=3.0.0)

## Dependencies

- `flutter` - Flutter SDK (>=3.0.0)
- `screenshot` - Screenshot capture plugin (^2.0.0)
- `nocterm` - Terminal UI framework (^0.1.0)
- `riverpod` - State management (^2.4.0)

## License

MIT

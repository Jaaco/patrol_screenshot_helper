# patrol_screenshot_cli

A terminal UI for discovering, filtering, and managing Patrol integration tests. Installable globally for use across all projects.

## Installation

### From Git

```bash
dart pub global activate --source git https://github.com/Jaaco/patrol_screenshot_helper.git --git-path patrol_screenshot_cli
```

### From Path (Development)

```bash
cd patrol_screenshot_cli
dart pub global activate --source path .
```

### From Pub (Once Published)

```bash
dart pub global activate patrol_screenshot_cli
```

## Usage

Once installed globally, run the command from any project directory:

```bash
patrol-screenshot-ui
```

This will launch the terminal UI, which automatically scans the `./integration-test/` directory for patrol tests.

## Features

- **Automatic Test Discovery** - Scans `./integration-test/` for all `*_test.dart` files
- **Real-time Search** - Filter tests by name, path, or description
- **Test Details** - View metadata including test cases and modification date
- **Keyboard Navigation** - Arrow keys for navigation, Enter to select, q to quit
- **No Flutter Dependency** - Pure Dart CLI tool, installable globally

## Key Bindings

| Key | Action |
|-----|--------|
| `↑/↓` | Navigate test list |
| `/` or `Ctrl+F` | Focus search bar |
| `Esc` | Exit search mode |
| `q` / `Ctrl+C` | Quit |

## Requirements

- Dart SDK >= 3.0.0

## Troubleshooting

**Command not found after installation**
- Ensure your Dart bin directory is in PATH: `$HOME/.pub-cache/bin`
- Try running: `export PATH="$PATH:$HOME/.pub-cache/bin"`

**No tests found**
- Ensure test files are in `./integration-test/` directory
- Test files must end with `_test.dart`

**Dependencies resolution fails**
- Update your Dart SDK: `dart pub global activate dart_sdk`
- Clear pub cache: `rm -rf ~/.pub-cache/hosted`

## License

MIT

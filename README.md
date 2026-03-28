# patrol_screenshot_helper

A Flutter helper package for capturing screenshots during Patrol integration tests, plus a CLI tool to run tests and save the captured images.

Add `screenshotWrapper()` and `takeScreenshot()` calls to your tests — the CLI intercepts the output and writes numbered PNG files to disk.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Jaaco/patrol_screenshot_helper/main/scripts/install.sh | bash
```

This installs `patrol-screenshot` globally so you can run it from any project.

Add the Flutter package to your project:

```yaml
dev_dependencies:
  patrol_screenshot_helper:
    git:
      url: https://github.com/Jaaco/patrol_screenshot_helper
      ref: main
```

## Example

In your patrol test:

```dart
import 'package:patrol_screenshot_helper/patrol_screenshot_helper.dart';

await $.pumpWidgetAndSettle(screenshotWrapper(const MyApp()));

await takeScreenshot('login_empty');   // → 1-login_empty.png
await takeScreenshot('dashboard');     // → 2-dashboard.png
```

Run from your project root:

```bash
patrol-screenshot integration_test/main_test.dart
patrol-screenshot integration_test/main_test.dart --device emulator-5554
patrol-screenshot integration_test/main_test.dart --output-dir screenshots/
```

Screenshots are saved to `test_results/run_1/screenshots/`, incrementing on each run.

## Configuration

Settings are resolved in this order (highest wins): CLI args → project config → global config → defaults.

**Global config** — applies to all projects on your machine:

```bash
~/.patrol_screenshot_helper/config.json
```

**Project config** — place in the root of your Flutter project:

```bash
.patrol_screenshot.json
```

Both files use the same shape — include only the keys you want to override:

```json
{
  "device": "chrome",
  "inputFolder": "integration_test",
  "outputFolder": "test_results"
}
```

## License

MIT

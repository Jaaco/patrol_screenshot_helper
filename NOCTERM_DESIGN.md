# Nocterm Integration Design for Patrol Screenshot Helper

**Status**: Research Complete | Design Finalized
**Date**: 2026-03-28
**Task**: psh-9s3

---

## Executive Summary

This document outlines the design for integrating Nocterm (a terminal UI framework for Dart) with `patrol_screenshot_helper` to create a terminal interface for discovering, listing, and managing Patrol integration tests.

**Key Objective**: Build a TUI that displays all Patrol integration tests found in `./integration-test/` with their metadata, allowing users to:
- Browse available tests
- Filter/search tests
- View test metadata (path, description, etc.)
- Trigger test execution with screenshot capture

---

## 1. Framework Analysis: Nocterm

### What is Nocterm?

Nocterm is a **declarative terminal UI framework for Dart** that mirrors Flutter's widget model. It allows developers familiar with Flutter to build sophisticated TUIs without manual terminal control code.

**Key Characteristics**:
- **Declarative**: Widget-based composition (Column, Row, Container, etc.)
- **Event-Driven**: Keyboard and mouse input handling
- **Stateful**: StatefulComponent + Riverpod integration for state management
- **Hot Reload**: Rapid iteration during development
- **Cross-Platform**: Windows, macOS, Linux support
- **Testing Framework**: Built-in matchers for TUI testing
- **Advanced Features**: Overlays, dialogs, scrollable lists, markdown rendering

### Why Nocterm for This Task?

1. **Familiar to Flutter developers**: Uses Flutter patterns and concepts
2. **Rich component library**: Text styling, lists, input fields, navigation
3. **Responsive**: Adapts to terminal size dynamically
4. **Testing support**: Matches the testing-first approach of patrol_screenshot_helper
5. **No dependencies on low-level terminal control**: Abstracts complexity

---

## 2. Architecture & Component Structure

### High-Level Application Flow

```
┌─────────────────────────────────────────┐
│  Nocterm Application                    │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐│
│  │  StateManager (Riverpod)            ││
│  │  - TestList state                   ││
│  │  - SelectedTest state               ││
│  │  - SearchQuery state                ││
│  │  - ExecutionStatus state            ││
│  └─────────────────────────────────────┘│
│           ↓                              │
│  ┌─────────────────────────────────────┐│
│  │  Main UI (StatefulComponent)        ││
│  │  ├─ Header Panel                    ││
│  │  ├─ Search/Filter Bar               ││
│  │  ├─ Test List (Scrollable)          ││
│  │  ├─ Test Details Panel              ││
│  │  └─ Footer/Controls Panel           ││
│  └─────────────────────────────────────┘│
│           ↓                              │
│  ┌─────────────────────────────────────┐│
│  │  Test Discovery Engine              ││
│  │  - Scans ./integration-test/        ││
│  │  - Parses test metadata             ││
│  │  - Indexes and caches results       ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### Component Hierarchy

```
RootComponent (MainApp)
├── HeaderPanel
│   └── RichText: "Patrol Screenshot Helper - Test Runner"
│
├── SearchBar
│   ├── TextField (query input)
│   └── RichText (search hints)
│
├── MainContent
│   ├── LeftPanel (List View)
│   │   └── TestListItem (repeated)
│   │       └── Highlight current selection
│   │
│   └── RightPanel (Detail View)
│       ├── TestName (large)
│       ├── FilePath
│       ├── TestDescription
│       └── MetadataDisplay
│
└── FooterPanel
    ├── KeyBindings (help text)
    ├── Status (running, idle, error)
    └── ActionButtons (Run, Cancel)
```

---

## 3. State Management Approach

### Riverpod Architecture

Use **Riverpod** (Nocterm-compatible provider library) for reactive state management:

```dart
// Core state providers
final testListProvider = FutureProvider<List<TestFile>>((ref) async {
  return TestDiscoveryEngine.scan('./integration-test/');
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTestsProvider = Provider<List<TestFile>>((ref) {
  final tests = ref.watch(testListProvider).maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );
  final query = ref.watch(searchQueryProvider);
  return TestFilter.apply(tests, query);
});

final selectedTestProvider = StateProvider<TestFile?>((ref) => null);

final executionStatusProvider = StateProvider<ExecutionStatus>(
  (ref) => ExecutionStatus.idle,
);
```

### State Flow

1. **Initialization**: `testListProvider` scans `./integration-test/` and caches results
2. **Search**: User types → `searchQueryProvider` updates → `filteredTestsProvider` recomputes
3. **Selection**: User navigates with arrow keys → `selectedTestProvider` updates → detail panel re-renders
4. **Execution**: User presses Enter/Run → `executionStatusProvider` updates → UI reflects status
5. **Results**: Test completes → state updated → results displayed in footer

---

## 4. Test Discovery Engine

### Discovery Algorithm

**Location**: `lib/src/test_discovery.dart`

```dart
class TestDiscoveryEngine {
  /// Scan ./integration-test/ for Dart test files
  static Future<List<TestFile>> scan(String baseDir) async {
    final tests = <TestFile>[];
    final dir = Directory(baseDir);

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('_test.dart')) {
        final test = _parseTestFile(entity);
        if (test != null) tests.add(test);
      }
    }

    return tests;
  }

  /// Extract metadata from test file
  static TestFile? _parseTestFile(File file) {
    final content = file.readAsStringSync();
    return TestFile(
      path: file.path,
      name: _extractTestName(content),
      description: _extractDescription(content),
      lastModified: file.lastModifiedSync(),
    );
  }
}
```

### Test File Model

```dart
class TestFile {
  final String path;              // e.g., integration-test/app_test.dart
  final String name;              // e.g., "App Initial State"
  final String description;       // Comments or group description
  final DateTime lastModified;
  final List<TestCase> testCases; // Individual test() calls found
}

class TestCase {
  final String name;
  final int lineNumber;
  final String? description;
}
```

### Discovery Strategy

1. **Recursive scan** of `./integration-test/` directory
2. **Pattern matching** for `*_test.dart` files
3. **AST parsing** (lightweight regex-based) to extract:
   - `testWidgets()` / `test()` function names
   - Comments and doc strings
   - Group descriptions (from `group()` blocks)
4. **Caching** to avoid re-scanning on every keystroke
5. **Background refresh** on file system changes (optional, v2)

---

## 5. User Interface Design

### Screen Layout

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
│   empty_state_handling      │                                 │
│   network_error_dialog      │ Modified: 2026-03-27 14:22     │
│   session_timeout           │                                 │
│   dark_mode_switch          │ Test Cases: 1                   │
│   form_validation           │   • testWidgets()              │
│   image_cache               │                                 │
│   notification_badge        │                                 │
│                             │                                 │
├─────────────────────────────┴────────────────────────────────┤
│ [▶ Run] [Cancel] | Idle | ↑↓: Select | Enter: Run | q: Quit │
└──────────────────────────────────────────────────────────────┘
```

### Key Bindings

| Key(s) | Action |
|--------|--------|
| `↑/↓` | Navigate test list |
| `Ctrl+F` / `/` | Focus search bar |
| `Esc` | Clear search / exit search mode |
| `Enter` | Run selected test |
| `Space` | Quick-select (for batch operations in v2) |
| `q` / `Ctrl+C` | Quit |
| `?` | Show help overlay |

### Interactive Features

1. **Search/Filter** (real-time)
   - Search by test name, file path, or description
   - Highlights matching text
   - Fuzzy matching support (v2)

2. **Test List**
   - Scrollable with mouse wheel support
   - Arrow key navigation
   - Keyboard focus management
   - Visual feedback on selection (highlight/color)

3. **Details Panel**
   - Displays full metadata for selected test
   - Shows last run time (if available)
   - Expandable for large descriptions

4. **Status Footer**
   - Current execution status (idle, running, passed, failed)
   - Test count and filtered count
   - Keyboard shortcuts reminder

---

## 6. State Management Implementation Details

### Riverpod Setup

```dart
// pubspec.yaml additions
dependencies:
  nocterm: ^0.1.0
  riverpod: ^2.0.0
  riverpod_generator: ^2.0.0  # For code generation

dev_dependencies:
  riverpod_generator: ^2.0.0
```

### Key Providers

```dart
// Test discovery (async)
final testListProvider = FutureProvider<List<TestFile>>((ref) {
  return TestDiscoveryEngine.scan('./integration-test/');
});

// Search input (sync state)
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered results (computed)
final filteredTestsProvider = Provider<List<TestFile>>((ref) {
  final allTests = ref.watch(testListProvider).maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return allTests;
  return allTests.where((test) =>
    test.name.toLowerCase().contains(query.toLowerCase())
  ).toList();
});

// Selected test index (for keyboard nav)
final selectedTestProvider = StateProvider<int>((ref) => 0);

// Current execution status
final executionStatusProvider = StateProvider<ExecutionStatus>(
  (ref) => ExecutionStatus.idle,
);
```

### Data Flow Example: Search

```
User types "login" →
  searchQueryProvider updated →
  filteredTestsProvider recomputes →
  UI tree rebuilt with new filtered list →
  TextField re-renders with new results
```

---

## 7. Integration with Existing Code

### Current Structure

The package currently provides:
- **Flutter integration**: `screenshotWrapper()`, `takeScreenshot()`
- **Bash CLI**: `patrol-screenshot` script
- **Protocol**: Structured print statements for screenshot capture

### Nocterm Integration (Non-Breaking)

```dart
// New file: lib/src/nocterm_ui.dart

import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';

class PatrolTestRunnerUI extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _PatrolTestRunnerState();
}

class _PatrolTestRunnerState extends State<PatrolTestRunnerUI> {
  late ProviderContainer container;

  @override
  void initState() {
    container = ProviderContainer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainAppWidget(container: container);
  }
}
```

### Executable Entry Point

```dart
// bin/patrol-screenshot-ui.dart (new)

import 'package:nocterm/nocterm.dart';
import 'package:patrol_screenshot_helper/src/nocterm_ui.dart';

void main() {
  runApp(
    PatrolTestRunnerUI(),
  );
}
```

### File Structure After Integration

```
lib/
├── patrol_screenshot_helper.dart       (existing)
├── src/
│   ├── screenshot_helper.dart          (existing)
│   ├── test_discovery.dart             (new)
│   ├── nocterm_ui.dart                 (new)
│   ├── ui/
│   │   ├── main_app.dart               (new)
│   │   ├── components/
│   │   │   ├── header_panel.dart       (new)
│   │   │   ├── search_bar.dart         (new)
│   │   │   ├── test_list.dart          (new)
│   │   │   ├── detail_panel.dart       (new)
│   │   │   └── footer_panel.dart       (new)
│   │   └── state.dart                  (Riverpod providers)
│   └── models/
│       └── test_file.dart              (new)
│
bin/
├── patrol-screenshot                   (existing bash CLI)
└── patrol-screenshot-ui                (new nocterm UI)
```

---

## 8. Implementation Phases

### Phase 1: Foundation (blocking psh-b8k)
- Add Nocterm + Riverpod to `pubspec.yaml`
- Implement `TestDiscoveryEngine`
- Create core Riverpod providers
- Build minimal `MainApp` component

### Phase 2: UI Components
- Implement `TestList` with keyboard navigation
- Add `SearchBar` with filtering
- Build `DetailPanel` for test metadata
- Create `HeaderPanel` and `FooterPanel`

### Phase 3: Interactivity
- Keyboard event handling (arrows, Enter, Escape)
- Mouse wheel support for scrolling
- Search text input handling
- Focus management between panels

### Phase 4: Test Execution
- Wire test runner to button/Enter key
- Capture and display execution status
- Parse `patrol test` output
- Display results in UI

### Phase 5: Polish & Refinement
- Styling and colors
- Error handling and recovery
- Performance optimization
- Documentation and examples

---

## 9. Design Decisions & Rationale

| Decision | Rationale |
|----------|-----------|
| **Riverpod** for state mgmt | Native Dart provider pattern; decouples UI from logic; testing-friendly |
| **TestDiscoveryEngine** (external) | Reusable; testable; separates discovery from UI |
| **FutureProvider** for initial scan | Async I/O (file system); easy error handling; caching |
| **StateProvider** for user input | Minimal; synchronous updates; integrates with Nocterm forms |
| **Lightweight parsing** for test names | Avoids AST dependencies; sufficient for MVP; extensible |
| **Left/right split layout** | Familiar to IDE users; scalable to terminal width |
| **Keyboard-first navigation** | Terminal-native; mouse support secondary |
| **No shell integration (yet)** | Keeps Dart/Nocterm scope clear; bash script remains separate tool |

---

## 10. Testing Strategy

### Unit Tests
- `test_discovery_test.dart`: File scanning, parsing correctness
- `state_test.dart`: Provider logic, filtering, sorting
- `models_test.dart`: Data structure validation

### Widget Tests (Nocterm)
```dart
testWidgets('TestList filters correctly', (tester) async {
  final container = ProviderContainer();
  // Seed test data
  // Trigger search
  // Verify filtered list renders
});
```

### Integration Tests
- E2E test: Scan → Select → Run test
- Keyboard navigation flow
- Error states (missing directory, no tests found)

---

## 11. Future Enhancements (v2+)

- **Fuzzy search**: Better test discovery UX
- **Test history**: Recent runs, pass/fail trends
- **Batch operations**: Run multiple tests
- **Filter by tags**: Group-based filtering
- **Output viewer**: Real-time test logs in split pane
- **Keyboard macros**: Record/replay navigation
- **Theme support**: Light/dark mode, custom colors
- **Configuration**: Save user preferences
- **Shell completion**: bash/zsh autocomplete for test names

---

## 12. Success Criteria

✅ **Phase 1 Complete When**:
1. Nocterm + Riverpod dependencies added to pubspec.yaml
2. TestDiscoveryEngine scans and parses ./integration-test/ correctly
3. Riverpod providers initialize without errors
4. Minimal Nocterm app renders (hello-world equivalent)

✅ **Overall Success When**:
1. User can start CLI and see all tests listed
2. Real-time search/filter works smoothly
3. Arrow keys navigate; Enter runs test
4. Test results visible in terminal
5. Documentation covers basic usage
6. No errors or crashes in normal workflows

---

## Appendix: Key References

- **Nocterm Docs**: https://docs.nocterm.dev/docs
- **Nocterm GitHub**: https://github.com/roamingjackrabbit/nocterm
- **Riverpod Docs**: https://riverpod.dev
- **Dart File I/O**: https://dart.dev/libraries/dart-io
- **Flutter Testing**: https://flutter.dev/docs/testing

---

**Document Version**: 1.0
**Author**: patrol_screenshot_helper/polecats/obsidian
**Last Updated**: 2026-03-28

# Nocterm API Research Document

## Overview

nocterm v0.1.0 is a Flutter-inspired terminal UI framework for Dart. This document provides a comprehensive reference of available public APIs and documents their current (mis)usage in patrol_screenshot_helper.

---

## Core APIs

### 1. **App Class** (`nocterm/src/app.dart`)

Main application entry point for running TUI applications.

#### Constructor
```dart
App({
  required RenderFunction onRender,
  KeyHandler? onKeyPress
})
```

#### Properties
- `terminal: Terminal` - Terminal instance for output control

#### Methods
- `Future<void> run()` - Start the application (enters alternate screen, hides cursor, sets up input handling)
- `void stop()` - Stop the application

#### Type Aliases
```dart
typedef RenderFunction = void Function(Frame frame);
typedef KeyHandler = void Function(String key);
```

#### Supported Key Events
- Arrow keys: `'up'`, `'down'`, `'left'`, `'right'`
- Special keys: `'enter'`, `'space'`, `'tab'`
- Regular character input
- Exit signals: `'q'` or Ctrl+C

---

### 2. **Frame Class** (`nocterm/src/frame.dart`)

Represents a single frame/screen to be rendered.

#### Constructor
```dart
Frame({
  required Size size,
  Buffer? previousBuffer
})
```

#### Properties
- `buffer: Buffer` - The drawing surface for this frame
- `size: Size` - Terminal dimensions (width, height)
- `area: Rect` - Full rectangle covering the terminal

#### Methods
- `void render(Terminal terminal)` - Render frame to terminal
- `void forceFullRedraw()` - Force complete redraw on next render (optimizes by tracking changed lines)

#### Features
- **Delta rendering**: Only redraws changed lines for performance
- **Buffer comparison**: Compares current frame to previous buffer to detect changes
- **ANSI cursor management**: Uses ANSI escape sequences for efficient cursor positioning

---

### 3. **Component Framework** (`nocterm/src/framework/framework.dart`)

Flutter-like component system for building TUI interfaces.

#### Base Classes

**Component** (abstract)
```dart
abstract class Component {
  const Component({this.key});
  final Key? key;
  Element createElement();
  static bool canUpdate(Component oldComponent, Component newComponent);
}
```

**SingleChildRenderObjectComponent** (extends RenderObjectComponent)
- Used for components with one child
- Examples: `Padding`, `Align`, `Text`, `SizedBox`, `Container`, `RichText`, `TextField`

**MultiChildRenderObjectComponent** (extends RenderObjectComponent)
- Used for components with multiple children
- Examples: `Row`, `Column`, `Stack`, `ListView`

#### Type Aliases
```dart
typedef ComponentBuilder = Component Function(BuildContext context);
typedef StateSetter = void Function(VoidCallback fn);
typedef VoidCallback = void Function();
typedef ElementVisitor = void Function(Element element);
```

---

### 4. **StatelessComponent**

Base class for components with no mutable state.

```dart
abstract class StatelessComponent extends Component {
  const StatelessComponent({super.key});

  @protected
  Component build(BuildContext context);

  @override
  StatelessElement createElement();
}
```

#### Example Usage
```dart
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Text('Hello World');
  }
}
```

---

### 5. **StatefulComponent**

Base class for components with mutable state.

```dart
abstract class StatefulComponent extends Component {
  const StatefulComponent({super.key});

  @override
  StatefulElement createElement();

  State createState();
}

abstract class State<T extends StatefulComponent> {
  late BuildContext context;

  @protected
  void setState(VoidCallback fn);

  @protected
  Component build(BuildContext context);

  @protected
  void initState() {}

  @protected
  void dispose() {}
}
```

---

### 6. **Basic Components** (`nocterm/src/components/basic.dart`)

#### Text
```dart
class Text extends SingleChildRenderObjectComponent {
  const Text(
    this.data, {
    Key? key,
    TextStyle? style,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  });
}
```

#### SizedBox
```dart
class SizedBox extends SingleChildRenderObjectComponent {
  const SizedBox({
    Key? key,
    double? width,
    double? height,
    Component? child,
  });
}
```

#### Padding
```dart
class Padding extends SingleChildRenderObjectComponent {
  const Padding({
    Key? key,
    required EdgeInsets padding,
    Component? child,
  });
}
```

#### Align
```dart
class Align extends SingleChildRenderObjectComponent {
  const Align({
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
    Component? child,
  });
}
```

#### Container
```dart
class Container extends SingleChildRenderObjectComponent {
  const Container({
    Key? key,
    Alignment? alignment,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    double? width,
    double? height,
    Component? child,
  });
}
```

---

### 7. **RichText Component** (`nocterm/src/components/rich_text.dart`)

Display text with multiple styles.

```dart
class RichText extends SingleChildRenderObjectComponent {
  const RichText({
    Key? key,
    required InlineSpan text,
    TextAlign textAlign = TextAlign.left,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
  });
}
```

**Current Usage in patrol_screenshot_helper:**
```dart
// lib/src/ui/components/header_panel.dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: '▶ ',
        style: TextStyle(color: Color.fromRGB(0, 200, 100)),
      ),
      TextSpan(
        text: 'Patrol Screenshot Helper - Test Runner',
        style: TextStyle(
          color: Color.fromRGB(255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

---

### 8. **Text Styling APIs**

#### TextSpan (`nocterm/src/painting/text_span.dart`)

**EXPORTED ONLY VIA `rich_text.dart`** - Not in main `nocterm.dart` exports.

```dart
class TextSpan extends InlineSpan {
  const TextSpan({
    String? text,
    List<InlineSpan>? children,
    TextStyle? style,
  });

  final String? text;
  final List<InlineSpan>? children;
}
```

**Public Methods:**
- `bool visitChildren(InlineSpanVisitor visitor)` - Visit all text spans
- `void computeToPlainText(StringBuffer buffer, {bool includePlaceholderOffsets})` - Extract plain text
- `List<StyledTextSegment> toStyledSegments([TextStyle? parentStyle])` - Get styled segments

**Key Features:**
- Immutable nested structure for styled text
- Supports text + children (text precedes children)
- Inherits `style` from parent `InlineSpan`

#### TextStyle (`nocterm/src/style.dart`)

```dart
class TextStyle {
  const TextStyle({
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  });

  // Properties
  final Color? color;
  final Color? backgroundColor;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;

  // Methods
  String toAnsi() // Convert to ANSI escape codes
  TextStyle copyWith({...}) // Create modified copy
  TextStyle merge(TextStyle? other) // Merge with another style
  static const String reset = '\x1b[0m'; // ANSI reset sequence
}
```

#### Color (`nocterm/src/style.dart`)

```dart
class Color {
  // Factory constructors
  const Color(int value) // From 0xRRGGBB integer
  const Color.fromRGB(int red, int green, int blue) // From RGB values
  static const Color defaultColor; // Terminal default

  // Properties
  final int red;
  final int green;
  final int blue;
  final bool isDefault;

  // Methods
  String toAnsi({bool background = false}) // ANSI escape code
}
```

#### Colors Class (predefined constants)
```dart
abstract class Colors {
  static const Color black = Color.fromRGB(24, 24, 28);
  static const Color red = Color.fromRGB(231, 97, 112);
  static const Color green = Color.fromRGB(139, 213, 152);
  static const Color yellow = Color.fromRGB(241, 213, 137);
  static const Color blue = Color.fromRGB(139, 179, 244);
  static const Color magenta = Color.fromRGB(198, 160, 246);
  static const Color cyan = Color.fromRGB(139, 213, 202);
  static const Color white = Color.fromRGB(248, 248, 242);
  static const Color grey = Color.fromRGB(146, 153, 166);

  // Bright variants
  static const Color brightBlack = Color.fromRGB(98, 104, 117);
  static const Color brightRed = Color.fromRGB(255, 139, 148);
  static const Color brightGreen = Color.fromRGB(163, 239, 178);
  static const Color brightYellow = Color.fromRGB(255, 234, 170);
  static const Color brightBlue = Color.fromRGB(163, 203, 255);
  static const Color brightMagenta = Color.fromRGB(224, 189, 255);
  static const Color brightCyan = Color.fromRGB(163, 239, 228);
  static const Color brightWhite = Color.fromRGB(255, 255, 255);
}
```

#### FontWeight & FontStyle
```dart
enum FontWeight {
  normal, // w400
  bold,   // w700
  w100, w200, w300, w400, w500, w600, w700, w800, w900
}

enum FontStyle {
  normal,
  italic,
}
```

---

### 9. **Layout Components**

#### Row/Column
```dart
class Row extends Flex {
  const Row({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    List<Component> children = const [],
  });
}

class Column extends Flex {
  const Column({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    List<Component> children = const [],
  });
}
```

#### Stack
```dart
class Stack extends MultiChildRenderObjectComponent {
  const Stack({
    Key? key,
    Alignment alignment = Alignment.topLeft,
    StackFit fit = StackFit.loose,
    TextDirection? textDirection,
    Clip clipBehavior = Clip.hardEdge,
    List<Component> children = const [],
  });
}
```

#### ListView
```dart
class ListView extends MultiChildRenderObjectComponent {
  const ListView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
    List<Component> children = const [],
  });
}
```

#### SingleChildScrollView
```dart
class SingleChildScrollView extends SingleChildRenderObjectComponent {
  const SingleChildScrollView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
    Component? child,
  });
}
```

---

### 10. **Spacing Components**

#### Spacer
```dart
class Spacer extends Component {
  const Spacer({Key? key, this.flex = 1});
  final int flex;
}
```

#### Divider
```dart
class Divider extends Component {
  const Divider({
    Key? key,
    this.height = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });
}
```

---

### 11. **Form/Input Components**

#### TextField
```dart
class TextField extends SingleChildRenderObjectComponent {
  const TextField({
    Key? key,
    TextEditingController? controller,
    String? placeholder,
    TextStyle? style,
    int? maxLines,
    int? minLines,
    int maxLength = 65536,
    bool obscureText = false,
    bool enabled = true,
  });
}
```

---

### 12. **Focus & Navigation**

#### FocusScope
```dart
class FocusScope extends Component {
  const FocusScope({
    Key? key,
    required Component child,
  });
}
```

#### Navigator
```dart
class Navigator extends Component {
  const Navigator({
    Key? key,
    List<Route> initialRoutes = const [],
    NavigatorObserver? observer,
  });

  // Methods available via context
  Future<T?> push<T>(Route<T> route);
  void pop<T>([T? result]);
  void popUntil(RoutePredicate predicate);
  void pushNamedAndRemoveUntil(String route, RoutePredicate predicate);
}
```

---

## Style & Decoration APIs

### EdgeInsets
```dart
class EdgeInsets {
  const EdgeInsets.all(double value);
  const EdgeInsets.symmetric({double? vertical, double? horizontal});
  const EdgeInsets.only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  });
  const EdgeInsets.fromLTRB(double left, double top, double right, double bottom);
}
```

### Alignment
```dart
class Alignment {
  static const Alignment topLeft = Alignment(-1.0, -1.0);
  static const Alignment topCenter = Alignment(0.0, -1.0);
  static const Alignment topRight = Alignment(1.0, -1.0);
  static const Alignment centerLeft = Alignment(-1.0, 0.0);
  static const Alignment center = Alignment(0.0, 0.0);
  static const Alignment centerRight = Alignment(1.0, 0.0);
  static const Alignment bottomLeft = Alignment(-1.0, 1.0);
  static const Alignment bottomCenter = Alignment(0.0, 1.0);
  static const Alignment bottomRight = Alignment(1.0, 1.0);
}
```

### Size
```dart
class Size {
  const Size(this.width, this.height);

  final double width;
  final double height;

  Size.fromRadius(double radius) : width = radius * 2, height = radius * 2;
}
```

---

## Known Misuses in Current Code

### 1. **Undefined Import in header_panel.dart**

**Location:** `lib/src/ui/components/header_panel.dart:2`

**Issue:**
```dart
import 'package:nocterm/src/components/rich_text.dart';
```

**Problem:**
- Imports internal API `rich_text.dart` instead of using main package export
- While this works, it bypasses the public API stability guarantee
- `TextSpan` is only exported via `rich_text.dart`, not via main `nocterm.dart`

**Correct Approach:**
- Import only from main package: `import 'package:nocterm/nocterm.dart';`
- `RichText` and `TextSpan` are both available through `rich_text.dart` export

**Current Code:**
```dart
import 'package:nocterm/nocterm.dart';
import 'package:nocterm/src/components/rich_text.dart';

class HeaderPanel extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Container(
      color: Color.fromRGB(30, 30, 30),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '▶ ',
                style: TextStyle(
                  color: Color.fromRGB(0, 200, 100),
                ),
              ),
              TextSpan(
                text: 'Patrol Screenshot Helper - Test Runner',
                style: TextStyle(
                  color: Color.fromRGB(255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Status:** Works but uses internal API. Need to verify `TextSpan` availability through main export.

---

## API Export Structure

### Main Export (`nocterm.dart`)
- `App`
- `Frame`
- `Size`
- `TextStyle`
- `Color`
- `Components:` Text, Container, Padding, Align, SizedBox, etc.
- `Framework:` Component, StatelessComponent, StatefulComponent, BuildContext
- `Navigation:` Navigator, Route, RouteSettings
- `Layout:` Row, Column, Stack, ListView, SingleChildScrollView, Spacer, Divider
- `Inputs:` TextField, FocusScope, KeyboardListener
- **NOTE:** `TextSpan` is NOT directly exported from main file
- **NOTE:** `TextSpan` IS exported from `src/components/rich_text.dart`

### Sub-exports
- `rich_text.dart` exports: `TextSpan`, `InlineSpan`, `TextOverflow`, `TextAlign`

---

## Type Aliases & Enums Used

### Enums
- `FontWeight` - normal, bold, w100-w900
- `FontStyle` - normal, italic
- `TextAlign` - left, right, center, justify
- `TextOverflow` - clip, ellipsis, fade, visible
- `Axis` - horizontal, vertical
- `MainAxisAlignment` - start, end, center, spaceBetween, spaceAround, spaceEvenly
- `CrossAxisAlignment` - start, end, center, stretch, baseline
- `Alignment` - various predefined alignments
- `StackFit` - loose, expand
- `Clip` - none, hardEdge, antiAlias, antiAliasWithSaveLayer

---

## Rendering Pipeline

```
App.run()
  ↓
App.onRender(Frame frame)
  ↓
User builds components (TextSpan with TextStyle, Container, etc.)
  ↓
Component.createElement() → Element
  ↓
Element.build() → Creates RenderObject
  ↓
Frame.render(Terminal terminal)
  ↓
Terminal writes ANSI escape sequences
```

---

## Summary of Available APIs for TUI Building

### For Text Rendering
✅ `Text(data, style, overflow, textAlign, maxLines)` - Simple text
✅ `RichText(text, softWrap, overflow, maxLines)` - Multi-styled text with `TextSpan`
✅ `TextSpan(text, children, style)` - Styled text segments (nested)
✅ `TextStyle(color, backgroundColor, fontWeight, fontStyle, decoration)` - Text styling
✅ `Color.fromRGB(r, g, b)` and predefined `Colors.*` constants

### For Layout
✅ `Container(color, padding, decoration, child)` - Decorated container
✅ `Padding(padding, child)` - Add spacing around widget
✅ `Align(alignment, child)` - Align child within parent
✅ `SizedBox(width, height, child)` - Fixed size box
✅ `Row/Column(children)` - Linear layout
✅ `Stack(children, alignment)` - Overlapping layout
✅ `ListView(children)` - Scrollable list
✅ `Spacer(flex)` - Flexible spacing
✅ `Divider(height, color)` - Visual separator

### For Input & Interaction
✅ `TextField(controller, placeholder, maxLines)` - Text input
✅ `KeyboardListener` - Capture keyboard events
✅ `FocusScope` - Focus management
✅ `Navigator` - Screen navigation

### For State Management
✅ `StatelessComponent` - For static components
✅ `StatefulComponent` + `State` - For components with mutable state
✅ `BuildContext` - Access to framework services

---

## Recommendations for the Fix Task

1. **Verify TextSpan is accessible** - Confirm that `TextSpan` can be imported via:
   - Direct import: `import 'package:nocterm/src/components/rich_text.dart';` ✓ (currently used)
   - Or through main export if re-exported

2. **Check for actual compilation errors** - The code may be working despite the "undefined method" error

3. **Possible fixes** (in order of preference):
   - Option A: Keep using `TextSpan` via `rich_text.dart` (already works)
   - Option B: Use `Text` with `TextStyle` instead of `RichText`/`TextSpan` (simpler alternative)
   - Option C: Check if `rich_text.dart` needs explicit export in main `nocterm.dart`

4. **Test all components** after fix to ensure:
   - `RichText` with `TextSpan` works correctly
   - Color/styling renders properly in terminal
   - No runtime errors occur


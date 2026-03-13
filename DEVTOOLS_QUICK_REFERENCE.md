# Flutter DevTools Quick Reference Guide

## Quick Commands

### Hot Reload
```bash
# In terminal where flutter run is active
r          # Hot reload
R          # Hot restart (full restart)
q          # Quit
h          # Help
```

### Launch DevTools
```bash
# Method 1: Global activation (one-time)
flutter pub global activate devtools
flutter pub global run devtools

# Method 2: From VS Code
Ctrl+Shift+P → "Dart: Open DevTools"

# Method 3: From running app
# Look for URL in console: http://127.0.0.1:9100
```

### Run Modes
```bash
flutter run              # Debug mode (default)
flutter run --profile    # Profile mode (for performance testing)
flutter run --release    # Release mode (production build)
```

---

## Debug Console Emoji Legend

Use consistent emoji prefixes for better log readability:

```dart
🚀  Initialization / Startup
📊  Data operations / State changes
🎨  UI changes / Theme updates
❌  Errors / Exceptions
⚠️  Warnings
✅  Success / Completion
⏱️  Performance / Timing
🔄  Reset / Refresh
🐛  Debug information
📍  Location / Navigation
📝  Form / Input
🌈  Color / Style changes
🔨  Build / Rebuild
🛑  Stop / Dispose
```

### Example Usage
```dart
debugPrint('🚀 App: Initializing...');
debugPrint('📊 Counter: Value changed to $_count');
debugPrint('🎨 Theme: Switched to dark mode');
debugPrint('❌ Error: Failed to load data');
debugPrint('✅ Success: Data saved');
debugPrint('⏱️ Performance: Operation took ${duration}ms');
```

---

## DevTools Tabs Overview

### 1. Widget Inspector
**Purpose:** Visual widget tree debugging

**Key Features:**
- Select Widget Mode
- Show Paint Baselines
- Show Guidelines
- Highlight Repaints
- Debug Paint

**Shortcuts:**
- Click widget in app → See in tree
- Click in tree → Highlight in app

### 2. Performance
**Purpose:** Frame rendering and CPU profiling

**Key Metrics:**
- Frame time: < 16ms (60 FPS)
- Build time
- Layout time
- Paint time

**Actions:**
- Record → Interact → Stop → Analyze
- Look for red bars (dropped frames)

### 3. Memory
**Purpose:** Memory usage and leak detection

**Key Actions:**
- Take snapshot
- Compare snapshots
- Look for undisposed objects

**Common Leaks:**
- AnimationController
- TextEditingController
- StreamSubscription
- Listeners

### 4. Network
**Purpose:** HTTP request monitoring

**Shows:**
- Request/response headers
- Response bodies
- Timing information
- Status codes

### 5. Logging
**Purpose:** Consolidated log view

**Features:**
- Filter by level
- Search logs
- Timestamp display
- Color coding

---

## Common Debugging Patterns

### Pattern 1: Lifecycle Debugging
```dart
@override
void initState() {
  super.initState();
  debugPrint('🚀 ${widget.runtimeType}: initState()');
}

@override
void didUpdateWidget(covariant OldWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  debugPrint('🔄 ${widget.runtimeType}: didUpdateWidget()');
}

@override
void dispose() {
  debugPrint('🛑 ${widget.runtimeType}: dispose()');
  super.dispose();
}

@override
Widget build(BuildContext context) {
  debugPrint('🔨 ${widget.runtimeType}: build()');
  return Container();
}
```

### Pattern 2: Performance Timing
```dart
void _performOperation() async {
  final stopwatch = Stopwatch()..start();
  debugPrint('⏱️ Operation: Starting...');
  
  // Your operation here
  await someAsyncOperation();
  
  stopwatch.stop();
  debugPrint('✅ Operation: Completed in ${stopwatch.elapsedMilliseconds}ms');
}
```

### Pattern 3: State Change Logging
```dart
void _updateState(String field, dynamic value) {
  setState(() {
    debugPrint('📊 State Update: $field = $value');
    // Update state
  });
}
```

### Pattern 4: Error Handling
```dart
try {
  debugPrint('🚀 Starting risky operation...');
  await riskyOperation();
  debugPrint('✅ Operation succeeded');
} catch (e, stackTrace) {
  debugPrint('❌ Error: $e');
  debugPrint('📍 Stack trace: $stackTrace');
  // Handle error
}
```

### Pattern 5: Conditional Debug Logging
```dart
void _debugLog(String message) {
  assert(() {
    debugPrint('🐛 DEBUG: $message');
    return true;
  }());
}

// Only logs in debug mode
_debugLog('This only appears in debug builds');
```

---

## Hot Reload Checklist

### ✅ Hot Reload Works For:
- Widget UI changes
- Text and style modifications
- Color and theme updates
- Layout changes
- Adding/removing widgets
- Changing widget properties

### ❌ Hot Reload Doesn't Work For:
- Changes in `main()`
- Changes in `initState()`
- Adding/removing dependencies
- Changing app initialization
- Modifying global variables
- Enum changes

**Solution:** Use Hot Restart (press `R`)

---

## Performance Optimization Checklist

### Before Optimization
1. ✅ Profile in release mode: `flutter run --profile`
2. ✅ Test on real device (not emulator)
3. ✅ Record baseline performance
4. ✅ Identify bottlenecks in DevTools

### Common Performance Issues

**Issue 1: Expensive Build Methods**
```dart
// ❌ Bad: Rebuilds entire list
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ Good: Only rebuilds changed items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

**Issue 2: Missing const Constructors**
```dart
// ❌ Bad: Creates new widget every build
Text('Hello')

// ✅ Good: Reuses widget instance
const Text('Hello')
```

**Issue 3: Unnecessary Rebuilds**
```dart
// ❌ Bad: Entire widget rebuilds
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveWidget(),  // Rebuilds unnecessarily
        SimpleWidget(),
      ],
    );
  }
}

// ✅ Good: Extract to const
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(),  // Only builds once
        const SimpleWidget(),
      ],
    );
  }
}
```

---

## Memory Leak Detection

### Common Leak Patterns

**Pattern 1: Undisposed Controllers**
```dart
// ❌ Bad: Memory leak
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  
  // Missing dispose!
}

// ✅ Good: Properly disposed
class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Pattern 2: Retained Listeners**
```dart
// ❌ Bad: Listener not removed
@override
void initState() {
  super.initState();
  someStream.listen((data) {
    // Handle data
  });
}

// ✅ Good: Listener removed
StreamSubscription? _subscription;

@override
void initState() {
  super.initState();
  _subscription = someStream.listen((data) {
    // Handle data
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### Memory Debugging Steps
1. Open DevTools → Memory tab
2. Take snapshot (baseline)
3. Perform action (navigate, load data)
4. Navigate back
5. Force garbage collection
6. Take another snapshot
7. Compare: Look for objects that should be gone

---

## Widget Inspector Tips

### Debugging Layout Issues

**Issue: Widget Overflow**
1. Enable "Debug Paint"
2. Look for red/yellow stripes
3. Check widget constraints
4. Use `Flexible` or `Expanded`

**Issue: Unexpected Size**
1. Select widget in inspector
2. Check "Size" in properties
3. Check "Constraints" (min/max)
4. Verify parent constraints

**Issue: Alignment Problems**
1. Enable "Show Guidelines"
2. Check `alignment` properties
3. Verify `MainAxisAlignment` and `CrossAxisAlignment`

### Inspector Shortcuts
- `p` - Toggle debug paint
- `i` - Toggle widget inspector
- `o` - Toggle platform (iOS/Android)
- `z` - Toggle construction lines

---

## Troubleshooting

### Hot Reload Not Working

**Problem:** Changes don't appear after hot reload

**Solutions:**
1. Try hot restart (`R`)
2. Check if changes are in `initState()` or `main()`
3. Verify file is saved
4. Check for syntax errors
5. Restart app completely

### DevTools Won't Open

**Problem:** DevTools fails to launch

**Solutions:**
```bash
# Reinstall DevTools
flutter pub global deactivate devtools
flutter pub global activate devtools

# Clear cache
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor
```

### Debug Console Not Showing Logs

**Problem:** `debugPrint()` statements not appearing

**Solutions:**
1. Verify Debug Console is open (View → Debug Console)
2. Check if running in debug mode
3. Try `print()` instead of `debugPrint()`
4. Restart debug session

### Performance Issues in DevTools

**Problem:** DevTools shows poor performance

**Solutions:**
1. Profile in release mode: `flutter run --profile`
2. Test on real device, not emulator
3. Disable debug paint and overlays
4. Check for expensive operations in build methods

---

## Best Practices Summary

### Development Workflow
1. ✅ Use Hot Reload for rapid iteration
2. ✅ Add debug logs for important operations
3. ✅ Profile performance regularly
4. ✅ Check memory usage during navigation
5. ✅ Use Widget Inspector for layout debugging

### Code Quality
1. ✅ Use `const` constructors where possible
2. ✅ Dispose controllers and subscriptions
3. ✅ Keep build methods pure and fast
4. ✅ Extract expensive widgets
5. ✅ Use `ListView.builder` for long lists

### Team Collaboration
1. ✅ Include debug logs in code
2. ✅ Document performance requirements
3. ✅ Share DevTools screenshots in PRs
4. ✅ Use consistent logging patterns
5. ✅ Profile before merging

---

## Keyboard Shortcuts

### VS Code
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+S` - Save (triggers hot reload if enabled)
- `F5` - Start debugging
- `Shift+F5` - Stop debugging
- `Ctrl+F5` - Run without debugging

### DevTools
- `Ctrl+F` - Search in current tab
- `Ctrl+Shift+F` - Global search
- `Esc` - Close dialogs

### Terminal (flutter run)
- `r` - Hot reload
- `R` - Hot restart
- `h` - Help
- `q` - Quit
- `d` - Detach (keep app running)
- `p` - Toggle debug paint
- `i` - Toggle widget inspector
- `o` - Toggle platform

---

## Additional Resources

### Official Docs
- [Hot Reload](https://docs.flutter.dev/development/tools/hot-reload)
- [DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Debugging](https://docs.flutter.dev/testing/debugging)
- [Performance](https://docs.flutter.dev/perf)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [Flutter Reddit](https://reddit.com/r/FlutterDev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

*Quick reference guide for Flutter development tools*
*Keep this handy during development!*

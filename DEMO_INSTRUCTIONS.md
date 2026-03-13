# Running the Stateless & Stateful Widget Demo

## Quick Start

### Option 1: Run Demo Standalone (Recommended)
This runs only the demo without the full app:

```bash
flutter run -t lib/demo_main.dart
```

### Option 2: Run Full App and Navigate to Demo
1. Run the main app:
```bash
flutter run
```

2. Modify `lib/main.dart` to show the demo by changing the home widget:
```dart
// In QlessApp class, change:
home: const AppEntry(),
// To:
home: const StatelessStatefulDemo(),
```

### Option 3: Add Navigation Button
Add a button in your existing screens to navigate to the demo:
```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/demo');
  },
  child: const Text('View Widget Demo'),
)
```

## What to Test

### 1. Counter Widget
- ✅ Click "Increase" button - counter should increment
- ✅ Click "Decrease" button - counter should decrement
- ✅ Click "Reset" button - counter should return to 0
- ✅ Verify the number updates immediately on each click

### 2. Theme Toggle Widget
- ✅ Toggle the switch from Light to Dark
- ✅ Observe the background color change
- ✅ Notice the icon change (sun to moon)
- ✅ Text color should adapt to the theme

### 3. Color Changer Widget
- ✅ Click "Change Color" button
- ✅ Watch the circle change colors smoothly
- ✅ Color name should update to match
- ✅ Button color should match the current color
- ✅ Cycles through: Red → Blue → Green → Purple → Orange → Teal

### 4. Static Header
- ✅ Header remains unchanged during all interactions
- ✅ Demonstrates Stateless widget behavior

## Taking Screenshots

### For Documentation:

1. **Initial State Screenshot**:
   - Launch the app
   - Take screenshot showing all widgets in default state
   - Counter at 0, Light mode, Red color

2. **After Interaction Screenshot**:
   - Increment counter to 5
   - Toggle to Dark mode
   - Change color to Blue
   - Take screenshot showing all changes

### Screenshot Locations:
- Android: Use device screenshot button or `adb shell screencap`
- iOS: Use simulator screenshot or device screenshot
- Desktop: Use OS screenshot tool

## Expected Behavior

### Stateless Widget (Header)
- Never changes during app lifecycle
- Only rebuilds if parent widget rebuilds with new props
- Demonstrates immutable widget concept

### Stateful Widgets (Counter, Theme, Color)
- Respond immediately to user interaction
- Update UI without page reload
- Maintain state across rebuilds
- Demonstrate mutable state management

## Troubleshooting

### Issue: App won't run
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
- Press 'r' in terminal for hot reload
- Press 'R' for hot restart
- Or stop and restart the app

### Issue: Demo not showing
- Verify you're running the correct entry point
- Check that imports are correct
- Ensure no syntax errors with `flutter analyze`

## Code Verification

Run these commands to verify everything is working:

```bash
# Check for errors
flutter analyze

# Format code
flutter format lib/

# Run tests (if available)
flutter test
```

## Understanding the Code

### Key Files:
- `lib/screens/stateless_stateful_demo.dart` - Main demo implementation
- `lib/demo_main.dart` - Standalone demo entry point
- `README.md` - Complete documentation
- `WIDGET_GUIDE.md` - Quick reference guide

### Widget Hierarchy:
```
StatelessStatefulDemo (Stateless)
├── StaticHeader (Stateless)
├── CounterWidget (Stateful)
├── ThemeToggleWidget (Stateful)
└── ColorChangerWidget (Stateful)
```

## Learning Objectives Checklist

After running the demo, you should understand:

- ✅ Difference between Stateless and Stateful widgets
- ✅ When to use each widget type
- ✅ How setState() triggers UI updates
- ✅ How to handle user interactions
- ✅ Widget lifecycle methods
- ✅ Performance implications of widget choices

## Next Steps

1. Experiment with the code:
   - Add more buttons to the counter
   - Add more colors to the color changer
   - Create your own stateful widget

2. Modify the examples:
   - Change the initial counter value
   - Add more theme options
   - Customize the animations

3. Build something new:
   - Create a todo list (Stateful)
   - Build a profile card (Stateless)
   - Make a simple game

## Questions to Consider

1. What happens if you remove `setState()` from the counter increment?
2. Can you convert the StaticHeader to a Stateful widget? Should you?
3. How would you share the counter value between multiple widgets?
4. What's the performance difference between Stateless and Stateful?

## Additional Experiments

### Experiment 1: Remove setState()
Try removing `setState()` from the increment method:
```dart
void _increment() {
  _count++;  // Without setState
}
```
Result: UI won't update even though the variable changes!

### Experiment 2: Add Logging
Add print statements to see when widgets rebuild:
```dart
@override
Widget build(BuildContext context) {
  print('Building CounterWidget');
  return ...;
}
```

### Experiment 3: Extract Widgets
Try extracting parts of the UI into separate widgets and observe rebuild behavior.

## Support

If you encounter issues:
1. Check the Flutter documentation
2. Review the code comments
3. Run `flutter doctor` to verify setup
4. Check the console for error messages

Happy coding! 🚀

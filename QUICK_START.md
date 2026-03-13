# Quick Start Guide

## Run the Demo in 3 Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the Demo
```bash
flutter run -t lib/demo_main.dart
```

### Step 3: Interact with Widgets
- Click buttons on the Counter widget
- Toggle the Theme switch
- Press "Change Color" button

## That's it! 🎉

## What You'll See

1. **Static Header** (Stateless) - Never changes
2. **Counter** (Stateful) - Click +/- buttons
3. **Theme Toggle** (Stateful) - Switch light/dark mode
4. **Color Changer** (Stateful) - Cycle through colors

## Need More Info?

- **Full Documentation**: See `README.md`
- **Detailed Instructions**: See `DEMO_INSTRUCTIONS.md`
- **Code Reference**: See `WIDGET_GUIDE.md`
- **Visual Diagrams**: See `VISUAL_GUIDE.md`
- **Submission Info**: See `SUBMISSION_SUMMARY.md`
- **Task Checklist**: See `CHECKLIST.md`

## Troubleshooting

### Demo won't run?
```bash
flutter clean
flutter pub get
flutter run -t lib/demo_main.dart
```

### Need to check for errors?
```bash
flutter analyze
```

### Want to format code?
```bash
flutter format lib/
```

## Key Files

- `lib/screens/stateless_stateful_demo.dart` - Main demo code
- `lib/demo_main.dart` - Demo entry point
- `lib/main.dart` - Full app entry point

## Quick Commands

```bash
# Run demo standalone
flutter run -t lib/demo_main.dart

# Run full app
flutter run

# Check for errors
flutter analyze

# Format code
flutter format lib/

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

## Learning Path

1. ✅ Run the demo
2. ✅ Interact with widgets
3. ✅ Read README.md
4. ✅ Review code in `stateless_stateful_demo.dart`
5. ✅ Understand Stateless vs Stateful
6. ✅ Experiment with modifications

## Next Steps

- Modify the counter initial value
- Add more colors to the color changer
- Create your own stateful widget
- Build a todo list app

Happy coding! 🚀

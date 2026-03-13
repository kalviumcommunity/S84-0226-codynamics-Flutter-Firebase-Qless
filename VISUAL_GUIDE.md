# Visual Guide - Stateless & Stateful Widgets Demo

## App Layout Overview

```
┌─────────────────────────────────────────┐
│  Stateless & Stateful Demo              │  ← App Bar
├─────────────────────────────────────────┤
│                                         │
│  ╔═══════════════════════════════════╗ │
│  ║   Interactive Widget Demo         ║ │  ← STATELESS
│  ║   Exploring Flutter Widget Types  ║ │     Static Header
│  ╚═══════════════════════════════════╝ │     (Never changes)
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Counter Widget                  │ │
│  │   Stateful Widget Example         │ │
│  │                                   │ │
│  │           5                       │ │  ← STATEFUL
│  │                                   │ │     Counter
│  │  [−] Decrease  [↻] Reset  [+] Increase │     (Changes on click)
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Theme Toggle Widget             │ │
│  │   Stateful Widget Example         │ │
│  │                                   │ │
│  │           🌙                      │ │  ← STATEFUL
│  │       Dark Mode                   │ │     Theme Toggle
│  │                                   │ │     (Switches themes)
│  │   Light  [====●]  Dark            │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Color Changer Widget            │ │
│  │   Stateful Widget Example         │ │
│  │                                   │ │
│  │           ●                       │ │  ← STATEFUL
│  │         Blue                      │ │     Color Changer
│  │                                   │ │     (Cycles colors)
│  │     [🎨 Change Color]             │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## Widget Interaction Flow

### Counter Widget Flow
```
User Action          State Change         UI Update
───────────────────────────────────────────────────
Click [+]      →    _count++       →    Display "6"
Click [−]      →    _count--       →    Display "4"
Click [↻]      →    _count = 0     →    Display "0"
```

### Theme Toggle Flow
```
User Action          State Change         UI Update
───────────────────────────────────────────────────
Toggle Switch  →    _isDarkMode    →    Background: Dark
                    = true              Icon: Moon
                                        Text: White

Toggle Switch  →    _isDarkMode    →    Background: Light
                    = false             Icon: Sun
                                        Text: Black
```

### Color Changer Flow
```
User Action          State Change         UI Update
───────────────────────────────────────────────────
Click Button   →    _colorIndex++  →    Circle: Blue
                    (0 → 1)             Label: "Blue"
                                        Button: Blue

Click Button   →    _colorIndex++  →    Circle: Green
                    (1 → 2)             Label: "Green"
                                        Button: Green
```

## State Management Diagram

```
┌─────────────────────────────────────────────────┐
│              StatelessWidget                    │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  Properties (final)                      │  │
│  │  - title: String                         │  │
│  │  - subtitle: String                      │  │
│  └──────────────────────────────────────────┘  │
│                    │                            │
│                    ▼                            │
│  ┌──────────────────────────────────────────┐  │
│  │  build(context)                          │  │
│  │  Returns: Widget tree                    │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  No state changes → No rebuilds                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│              StatefulWidget                     │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  State Object                            │  │
│  │  - _count: int                           │  │
│  │  - _isDarkMode: bool                     │  │
│  │  - _colorIndex: int                      │  │
│  └──────────────────────────────────────────┘  │
│                    │                            │
│                    ▼                            │
│  ┌──────────────────────────────────────────┐  │
│  │  User Interaction                        │  │
│  │  (Button press, Switch toggle)           │  │
│  └──────────────────────────────────────────┘  │
│                    │                            │
│                    ▼                            │
│  ┌──────────────────────────────────────────┐  │
│  │  setState(() {                           │  │
│  │    // Modify state                       │  │
│  │  })                                      │  │
│  └──────────────────────────────────────────┘  │
│                    │                            │
│                    ▼                            │
│  ┌──────────────────────────────────────────┐  │
│  │  build(context)                          │  │
│  │  Returns: Updated widget tree            │  │
│  └──────────────────────────────────────────┘  │
│                    │                            │
│                    ▼                            │
│  ┌──────────────────────────────────────────┐  │
│  │  UI Updates on Screen                    │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Widget Lifecycle Comparison

### Stateless Widget Lifecycle
```
┌──────────────┐
│ Constructor  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   build()    │ ← Called when inserted into tree
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Rendered   │
└──────────────┘
```

### Stateful Widget Lifecycle
```
┌──────────────┐
│ Constructor  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ createState()│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ initState()  │ ← Initialize state
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   build()    │ ← Initial render
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Rendered   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ setState()   │ ← User interaction
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   build()    │ ← Rebuild
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Updated UI  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  dispose()   │ ← Cleanup
└──────────────┘
```

## Color Cycle Visualization

```
Click 1    Click 2    Click 3    Click 4    Click 5    Click 6    Click 7
   │          │          │          │          │          │          │
   ▼          ▼          ▼          ▼          ▼          ▼          ▼
  Red  →    Blue   →   Green  →  Purple →  Orange →   Teal   →    Red
  ●         ●          ●         ●         ●          ●          ●
Index 0    Index 1    Index 2   Index 3   Index 4    Index 5    Index 0
                                                                  (loops)
```

## Theme States Visualization

```
Light Mode                    Dark Mode
┌─────────────────┐          ┌─────────────────┐
│ ☀️  Light Mode  │          │ 🌙  Dark Mode   │
│                 │          │                 │
│ Background:     │          │ Background:     │
│   White         │          │   Dark Gray     │
│                 │          │                 │
│ Text:           │          │ Text:           │
│   Black         │          │   White         │
│                 │          │                 │
│ Icon:           │          │ Icon:           │
│   Sun (Orange)  │          │   Moon (Yellow) │
└─────────────────┘          └─────────────────┘
```

## Counter States Visualization

```
Initial State      After +3         After Reset
┌──────────┐      ┌──────────┐      ┌──────────┐
│          │      │          │      │          │
│    0     │  →   │    3     │  →   │    0     │
│          │      │          │      │          │
└──────────┘      └──────────┘      └──────────┘
```

## Code-to-UI Mapping

### Stateless Widget
```dart
class StaticHeader extends StatelessWidget {
  final String title;        // ← Props (immutable)
  final String subtitle;     // ← Props (immutable)
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(title),       // ← Displays prop
          Text(subtitle),    // ← Displays prop
        ],
      ),
    );
  }
}
```
```
┌─────────────────────────┐
│  Interactive Widget     │ ← title prop
│  Demo                   │
│  Exploring Flutter      │ ← subtitle prop
│  Widget Types           │
└─────────────────────────┘
```

### Stateful Widget
```dart
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;          // ← Mutable state
  
  void _increment() {
    setState(() {
      _count++;            // ← State change
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),   // ← Displays state
        ElevatedButton(
          onPressed: _increment,  // ← Triggers state change
          child: Text('Increase'),
        ),
      ],
    );
  }
}
```
```
┌─────────────────────────┐
│         5               │ ← _count state
│                         │
│  [+] Increase           │ ← Calls _increment()
└─────────────────────────┘
```

## Performance Comparison

```
Stateless Widget          Stateful Widget
─────────────────         ─────────────────
Memory: Low               Memory: Higher
Rebuilds: Rare            Rebuilds: Frequent
Speed: Fast               Speed: Slightly slower
Use: Static UI            Use: Interactive UI

Example:                  Example:
- Labels                  - Forms
- Icons                   - Buttons
- Images                  - Animations
- Layouts                 - Counters
```

## Best Practices Visual

```
✅ DO                              ❌ DON'T
─────────────────────────────────────────────────
Use Stateless by default          Use Stateful everywhere
Keep state minimal                Store everything in state
Use const constructors            Forget const
Lift state up when sharing        Duplicate state
Call setState for changes         Modify state directly

Example:
✅ const Text('Hello')            ❌ Text('Hello')
✅ setState(() => count++)        ❌ count++; build()
```

## Testing Scenarios

```
Scenario 1: Counter Test
─────────────────────────
Initial: 0
Action:  Click [+] 3 times
Result:  Display shows "3"
✓ Pass if number updates

Scenario 2: Theme Test
──────────────────────
Initial: Light mode (white bg)
Action:  Toggle switch
Result:  Dark mode (dark bg)
✓ Pass if colors change

Scenario 3: Color Test
──────────────────────
Initial: Red circle
Action:  Click button 2 times
Result:  Green circle
✓ Pass if color cycles correctly

Scenario 4: Static Test
───────────────────────
Initial: Header displays title
Action:  Interact with other widgets
Result:  Header remains unchanged
✓ Pass if header never changes
```

## Summary

This visual guide illustrates:
- Widget hierarchy and layout
- State management flow
- Lifecycle differences
- Interaction patterns
- Code-to-UI relationships
- Performance characteristics
- Testing scenarios

Use this guide alongside the code to understand how Stateless and Stateful widgets work in Flutter!

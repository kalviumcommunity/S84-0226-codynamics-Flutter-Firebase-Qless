# Flutter Widget Quick Reference Guide

## Stateless vs Stateful Widgets Comparison

| Aspect | Stateless Widget | Stateful Widget |
|--------|-----------------|-----------------|
| **State** | Immutable, no internal state | Mutable, maintains internal state |
| **Rebuilds** | Only when parent rebuilds | When setState() is called |
| **Performance** | Faster, less memory | Slightly slower, more memory |
| **Use Case** | Static content | Interactive content |
| **Lifecycle** | Simple (build only) | Complex (initState, build, dispose) |
| **Example** | Text, Icon, Container | TextField, Checkbox, Counter |

## When to Use Each Type

### Use Stateless Widget When:
- ✅ Displaying static text or images
- ✅ Creating layout containers
- ✅ Building reusable UI components that don't change
- ✅ Showing data passed from parent widgets
- ✅ Performance is critical and no state is needed

### Use Stateful Widget When:
- ✅ Handling user input (buttons, forms, gestures)
- ✅ Managing animations
- ✅ Fetching data from APIs
- ✅ Implementing timers or periodic updates
- ✅ Tracking UI state (selected items, expanded panels)

## Code Templates

### Stateless Widget Template
```dart
class MyWidget extends StatelessWidget {
  final String data;
  
  const MyWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(data),
    );
  }
}
```

### Stateful Widget Template
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // State variables
  int _counter = 0;

  // State modification methods
  void _updateCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize state here
  }

  @override
  void dispose() {
    // Clean up resources here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Counter: $_counter'),
          ElevatedButton(
            onPressed: _updateCounter,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
```

## Common Patterns

### Pattern 1: Stateless Parent with Stateful Children
```dart
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticHeader(),  // Stateless
        CounterWidget(),        // Stateful
        const Footer(),         // Stateless
      ],
    );
  }
}
```

### Pattern 2: Lifting State Up
```dart
// Parent manages state
class ParentWidget extends StatefulWidget {
  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int _sharedValue = 0;

  void _updateValue(int newValue) {
    setState(() {
      _sharedValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChildWidget(
          value: _sharedValue,
          onChanged: _updateValue,
        ),
      ],
    );
  }
}

// Child receives state via props
class ChildWidget extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const ChildWidget({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onChanged(value + 1),
      child: Text('Value: $value'),
    );
  }
}
```

## setState() Best Practices

### ✅ DO
```dart
void _updateData() {
  setState(() {
    _counter++;
    _isLoading = false;
  });
}
```

### ❌ DON'T
```dart
void _updateData() {
  _counter++;  // Wrong: modifying state outside setState
  setState(() {
    // Empty or unrelated code
  });
}
```

### ✅ DO (Async Operations)
```dart
Future<void> _fetchData() async {
  final data = await api.getData();
  setState(() {
    _data = data;
  });
}
```

## Performance Tips

1. **Use const constructors** when possible:
```dart
const Text('Hello')  // Better
Text('Hello')        // Works but less efficient
```

2. **Extract static widgets**:
```dart
// Bad: Rebuilds header every time
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(child: Text('Header')),  // Rebuilds unnecessarily
      Text('$_counter'),
    ],
  );
}

// Good: Header is const
Widget build(BuildContext context) {
  return Column(
    children: [
      const _Header(),  // Won't rebuild
      Text('$_counter'),
    ],
  );
}
```

3. **Minimize setState() scope**:
```dart
// Only rebuild what changes
setState(() {
  _counter++;  // Only this changes
});
```

## Common Mistakes to Avoid

1. ❌ Using Stateful widget when Stateless would work
2. ❌ Calling setState() in build() method
3. ❌ Modifying state outside setState()
4. ❌ Not disposing controllers and listeners
5. ❌ Creating new objects in build() method repeatedly

## Testing Widgets

### Testing Stateless Widget
```dart
testWidgets('StaticHeader displays title', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: StaticHeader(
        title: 'Test Title',
        subtitle: 'Test Subtitle',
      ),
    ),
  );

  expect(find.text('Test Title'), findsOneWidget);
});
```

### Testing Stateful Widget
```dart
testWidgets('Counter increments', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: CounterWidget()),
  );

  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

## Additional Resources

- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Building Layouts](https://docs.flutter.dev/ui/layout)
- [Adding Interactivity](https://docs.flutter.dev/ui/interactivity)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)

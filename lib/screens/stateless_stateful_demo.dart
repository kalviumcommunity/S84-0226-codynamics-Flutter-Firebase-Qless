import 'package:flutter/material.dart';

/// Demo app showcasing Stateless and Stateful widgets
class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateless & Stateful Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stateless Widget Example - Static Header
            const StaticHeader(
              title: 'Interactive Widget Demo',
              subtitle: 'Exploring Flutter Widget Types',
            ),
            
            const SizedBox(height: 20),
            
            // Stateful Widget Example - Counter
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CounterWidget(),
            ),
            
            const SizedBox(height: 20),
            
            // Stateful Widget Example - Theme Toggle
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ThemeToggleWidget(),
            ),
            
            const SizedBox(height: 20),
            
            // Stateful Widget Example - Color Changer
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ColorChangerWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

/// STATELESS WIDGET EXAMPLE
/// This widget displays static content that doesn't change
class StaticHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const StaticHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// STATEFUL WIDGET EXAMPLE 1: Counter
/// This widget maintains a count state that changes on button press
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _decrement() {
    setState(() {
      _count--;
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Counter Widget',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stateful Widget Example',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$_count',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  label: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// STATEFUL WIDGET EXAMPLE 2: Theme Toggle
/// This widget toggles between light and dark mode
class ThemeToggleWidget extends StatefulWidget {
  const ThemeToggleWidget({super.key});

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Theme Toggle Widget',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stateful Widget Example',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 64,
              color: _isDarkMode ? Colors.yellow : Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              _isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Light',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[400] : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    _toggleTheme();
                  },
                  activeTrackColor: Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dark',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// STATEFUL WIDGET EXAMPLE 3: Color Changer
/// This widget cycles through different colors on tap
class ColorChangerWidget extends StatefulWidget {
  const ColorChangerWidget({super.key});

  @override
  State<ColorChangerWidget> createState() => _ColorChangerWidgetState();
}

class _ColorChangerWidgetState extends State<ColorChangerWidget> {
  int _colorIndex = 0;
  
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  final List<String> _colorNames = [
    'Red',
    'Blue',
    'Green',
    'Purple',
    'Orange',
    'Teal',
  ];

  void _changeColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Color Changer Widget',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stateful Widget Example',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _colors[_colorIndex],
                borderRadius: BorderRadius.circular(75),
                boxShadow: [
                  BoxShadow(
                    color: _colors[_colorIndex].withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.palette,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _colorNames[_colorIndex],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _colors[_colorIndex],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _changeColor,
              icon: const Icon(Icons.color_lens),
              label: const Text('Change Color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colors[_colorIndex],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

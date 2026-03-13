import 'package:flutter/material.dart';

/// Demo screen showcasing Hot Reload, Debug Console, and DevTools features
class DevToolsDemo extends StatefulWidget {
  const DevToolsDemo({super.key});

  @override
  State<DevToolsDemo> createState() => _DevToolsDemoState();
}

class _DevToolsDemoState extends State<DevToolsDemo>
    with SingleTickerProviderStateMixin {
  // State variables for demonstration
  int _counter = 0;
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Color> _colorPalette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 DevToolsDemo: initState() called');

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    debugPrint('✅ DevToolsDemo: Animation controller initialized');
  }

  @override
  void dispose() {
    debugPrint('🛑 DevToolsDemo: dispose() called');
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      debugPrint('📊 Counter incremented to: $_counter');
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        debugPrint('📉 Counter decremented to: $_counter');
      } else {
        debugPrint('⚠️ Counter is already at 0, cannot decrement');
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      debugPrint('🔄 Counter reset to: $_counter');
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      debugPrint('🎨 Theme toggled to: ${_isDarkMode ? "Dark" : "Light"} mode');
    });
  }

  void _changeColor() {
    setState(() {
      final currentIndex = _colorPalette.indexOf(_selectedColor);
      final nextIndex = (currentIndex + 1) % _colorPalette.length;
      _selectedColor = _colorPalette[nextIndex];
      debugPrint('🌈 Color changed to: $_selectedColor');
    });
  }

  void _simulateError() {
    debugPrint('❌ Simulating an error...');
    try {
      throw Exception('This is a simulated error for debugging purposes');
    } catch (e, stackTrace) {
      debugPrint('🐛 Error caught: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
  }

  void _performHeavyOperation() {
    debugPrint('⏳ Starting heavy operation...');
    final startTime = DateTime.now();

    // Simulate heavy computation
    int sum = 0;
    for (int i = 0; i < 1000000; i++) {
      sum += i;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint('✅ Heavy operation completed in ${duration.inMilliseconds}ms');
    debugPrint('📈 Result: $sum');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 DevToolsDemo: build() method called');

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hot Reload & DevTools Demo'),
        backgroundColor: _selectedColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Counter Section
            _buildCounterSection(),
            const SizedBox(height: 16),

            // Color Picker Section
            _buildColorSection(),
            const SizedBox(height: 16),

            // Debug Actions Section
            _buildDebugActionsSection(),
            const SizedBox(height: 16),

            // Info Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.developer_mode,
              size: 48,
              color: _selectedColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Flutter DevTools Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try Hot Reload by changing colors, text, or layouts!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Counter Demo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _selectedColor, width: 2),
                ),
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _selectedColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _decrementCounter,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Color Selector',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 100,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Current Color',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _changeColor,
              icon: const Icon(Icons.palette),
              label: const Text('Change Color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugActionsSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Debug Console Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Check your Debug Console for logs!',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _simulateError,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Simulate Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _performHeavyOperation,
                  icon: const Icon(Icons.speed),
                  label: const Text('Heavy Operation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
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

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _selectedColor),
                const SizedBox(width: 8),
                Text(
                  'How to Use',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Hot Reload', 'Press "r" in terminal or save file'),
            _buildInfoItem('Debug Console', 'View logs in VS Code Debug Console'),
            _buildInfoItem('DevTools', 'Open from VS Code command palette'),
            _buildInfoItem('Widget Inspector', 'Examine widget tree visually'),
            _buildInfoItem('Performance', 'Monitor frame rendering times'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: _selectedColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? Colors.grey[300] : Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

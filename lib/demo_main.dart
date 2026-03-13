import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/stateless_stateful_demo.dart';

/// Standalone entry point for the Stateless/Stateful Widget Demo
/// Run this file directly to see the demo without the full app
void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const StatelessStatefulDemo(),
    );
  }
}

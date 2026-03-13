import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/forms_demo.dart';

/// Standalone entry point for the Forms Demo
/// Run this file directly to see the forms examples
void main() {
  runApp(const FormsApp());
}

class FormsApp extends StatelessWidget {
  const FormsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forms Demo',
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
      home: const FormsDemo(),
    );
  }
}

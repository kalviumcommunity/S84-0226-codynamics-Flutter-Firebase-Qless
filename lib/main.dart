import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/customer/customer_landing_page.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const QlessApp());
}

class QlessApp extends StatelessWidget {
  const QlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qless',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 57,
          ),
          displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 45,
          ),
          displaySmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 32,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 28,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          titleMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
          ),
          labelLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          labelMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          labelSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }
    return const CustomerLandingPage();
  }
}


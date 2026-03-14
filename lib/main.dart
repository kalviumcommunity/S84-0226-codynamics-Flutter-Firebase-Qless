import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/customer/customer_landing_page.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/forms_demo.dart';
import 'screens/devtools_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Firebase app already initialized, which can happen during hot reload
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  runApp(const QlessApp());
}

class QlessApp extends StatelessWidget {
  const QlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qless',
      debugShowCheckedModeBanner: false,
      routes: {
        '/demo': (context) => const StatelessStatefulDemo(),
        '/forms': (context) => const FormsDemo(),
        '/devtools': (context) => const DevToolsDemo(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .copyWith(
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
              bodyLarge: GoogleFonts.inter(fontSize: 16),
              bodyMedium: GoogleFonts.inter(fontSize: 14),
              bodySmall: GoogleFonts.inter(fontSize: 12),
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

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(
            onComplete: () {
              // This splash is display-only while Firebase resolves persisted auth state.
            },
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong. Please restart the app.')),
          );
        }
        if (snapshot.hasData) {
          return _RoleBasedHome(user: snapshot.data!);
        }
        return AuthScreen(
          onAuthSuccess: () {
            // StreamBuilder updates automatically when auth state changes.
          },
        );
      },
    );
  }
}

class _RoleBasedHome extends StatelessWidget {
  final User user;

  const _RoleBasedHome({required this.user});

  Future<String> _resolveRole() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        return 'user';
      }

      final data = doc.data();
      final role = data?['role'] as String?;
      if (role == 'vendor' || role == 'user') {
        return role!;
      }

      final hasVendorFields =
          (data?['shopName'] as String?)?.isNotEmpty == true ||
              (data?['ownerName'] as String?)?.isNotEmpty == true;
      return hasVendorFields ? 'vendor' : 'user';
    } catch (_) {
      return 'user';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _resolveRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data ?? 'user';
        if (role == 'vendor') {
          return const AdminDashboard();
        }
        return const CustomerLandingPage(isAuthenticatedUser: true);
      },
    );
  }
}

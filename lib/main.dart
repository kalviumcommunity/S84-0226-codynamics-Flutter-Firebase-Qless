import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/cart_provider.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/customer/customer_landing_page.dart';
import 'screens/customer/customer_main_screen.dart';
import 'screens/vendor/vendor_dashboard.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/forms_demo.dart';
import 'screens/devtools_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file if available - continue even if missing
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Loaded .env file successfully');
  } catch (e) {
    print('⚠️ .env file not found or error loading: $e - Continuing without .env');
  }

  // Initialize Firebase - continue even if it fails
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    // Firebase app already initialized, which can happen during hot reload
    if (e.toString().contains('duplicate-app')) {
      print('ℹ️ Firebase already initialized (duplicate-app)');
    } else {
      print('⚠️ Firebase initialization failed: $e');
      print('⚠️ App will continue but some features may not work.');
    }
  }

  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (_) => VendorProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const QlessApp(),
    ),
  );
}

class QlessApp extends StatelessWidget {
  const QlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        return MaterialApp(
          key: ValueKey(authSnapshot.data?.uid ?? 'logged_out'),
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
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
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
      home: _buildHome(authSnapshot),
    );
  },
  );
}

  Widget _buildHome(AsyncSnapshot<User?> snapshot) {
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
  }
}

class _RoleBasedHome extends StatelessWidget {
  final User user;

  const _RoleBasedHome({required this.user});

  Future<String> _resolveRole() async {
    try {
      debugPrint('🔍 Starting role resolution for user: ${user.uid}');

      // Fast timeout: check user document quickly, fall back to default user role to prevent startup hang
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 2));

      if (!doc.exists) {
        debugPrint('❌ No user document found for ${user.uid}, defaulting to user');
        return 'user';
      }

      final data = doc.data();
      debugPrint('📄 User document data: $data');
      
      final role = data?['role'] as String?;
      debugPrint('🔍 Extracted role field: "$role"');
      
      // Check for explicit role field first
      if (role != null && role.isNotEmpty) {
        // Support admin, superadmin, vendor, and user roles
        if (role == 'admin' || role == 'superadmin') {
          debugPrint('✅ Resolved role: admin (from role field: $role)');
          return 'admin';
        } else if (role == 'vendor') {
          debugPrint('✅ Resolved role: vendor (from role field)');
          return 'vendor';
        } else if (role == 'user') {
          debugPrint('✅ Resolved role: user (from role field)');
          return 'user';
        } else {
          debugPrint('⚠️ Unknown role value: "$role", defaulting to user');
          return 'user';
        }
      }

      // Fallback: check for vendor-specific fields
      final shopName = data?['shopName'] as String?;
      final ownerName = data?['ownerName'] as String?;
      debugPrint('🔍 Checking vendor fields - shopName: "$shopName", ownerName: "$ownerName"');
      
      final hasVendorFields =
          (shopName?.isNotEmpty == true) || (ownerName?.isNotEmpty == true);
      final fallbackRole = hasVendorFields ? 'vendor' : 'user';
      debugPrint('✅ Resolved role from fields: $fallbackRole');
      return fallbackRole;
    } catch (e) {
      debugPrint('❌ Error resolving role: $e');
      // In case of timeout or offline without cache, default to user
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
        debugPrint('🚀 Routing to: $role dashboard for user: ${user.uid}');
        
        // Route based on role - STRICT matching
        if (role == 'admin' || role == 'superadmin') {
          debugPrint('✅ Loading AdminDashboard');
          return const AdminDashboard();
        } else if (role == 'vendor') {
          debugPrint('✅ Loading VendorDashboard');
          return const VendorDashboard();
        } else {
          debugPrint('✅ Loading CustomerLandingPage');
          return const CustomerLandingPage(isAuthenticatedUser: true);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates local image assets and Flutter built-in icons together.
class AssetDemoScreen extends StatelessWidget {
  const AssetDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Demo'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── App Logo ────────────────────────────────────────────────
            const Text(
              'App Logo (local image)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 24),

            // ── Banner image ─────────────────────────────────────────────
            const Text(
              'Banner (local image)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/banner.png',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // ── Background container ─────────────────────────────────────
            const Text(
              'Background Image (AssetImage)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  'Welcome to Qless!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Icon assets (custom PNGs) ────────────────────────────────
            const Text(
              'Custom Icon Assets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/icons/star.png', width: 60, height: 60),
                    const SizedBox(height: 4),
                    const Text('star.png'),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/profile.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 4),
                    const Text('profile.png'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Material icons ───────────────────────────────────────────
            const Text(
              'Built-in Material Icons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.flutter_dash, color: Colors.blue, size: 36),
                SizedBox(width: 16),
                Icon(Icons.star, color: Colors.amber, size: 36),
                SizedBox(width: 16),
                Icon(Icons.android, color: Colors.green, size: 36),
                SizedBox(width: 16),
                Icon(Icons.apple, color: Colors.grey, size: 36),
                SizedBox(width: 16),
                Icon(Icons.restaurant, color: Colors.deepOrange, size: 36),
              ],
            ),

            const SizedBox(height: 24),

            // ── Cupertino icons ──────────────────────────────────────────
            const Text(
              'Built-in Cupertino Icons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.heart, color: Colors.red, size: 36),
                SizedBox(width: 16),
                Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 36),
                SizedBox(width: 16),
                Icon(CupertinoIcons.person_fill, color: Colors.blueGrey, size: 36),
                SizedBox(width: 16),
                Icon(CupertinoIcons.cart_fill, color: Colors.deepOrange, size: 36),
              ],
            ),

            const SizedBox(height: 32),

            // ── Icon + Text row ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 32),
                SizedBox(width: 10),
                Text('Starred Vendor', style: TextStyle(fontSize: 18)),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Powered by Flutter',
              style: TextStyle(fontSize: 18, color: Colors.deepOrange),
            ),
          ],
        ),
      ),
    );
  }
}

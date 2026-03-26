import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qless/screens/auth/auth_screen.dart';
import 'package:qless/screens/admin/admin_dashboard.dart';
import 'package:qless/screens/responsive_home.dart';
import 'package:qless/screens/customer/shop_menu_screen.dart';
import 'package:qless/screens/customer/available_shops_screen.dart';
import 'package:qless/services/firestore_service.dart';
import 'package:qless/screens/customer/data_seeder_util.dart';
import 'order_tracking_screen.dart';
import 'my_orders_screen.dart';

import '../../widgets/live_queue_widget.dart';
import '../../widgets/animated_food_hero.dart';

class CustomerLandingPage extends StatelessWidget {
  final bool isAuthenticatedUser;

  const CustomerLandingPage({
    super.key,
    this.isAuthenticatedUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAuthenticatedUser
          ? AppBar(
              title: Text(
                'Qless',
                style: GoogleFonts.righteous(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showProfileSheet(context),
                  icon: const Icon(Icons.account_circle_outlined),
                  tooltip: 'Profile',
                ),
              ],
            )
          : null,
      floatingActionButton: isAuthenticatedUser
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'logout_btn',
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
                const SizedBox(height: 16),
                FloatingActionButton.small(
                  heroTag: 'responsive_demo',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResponsiveHome()),
                    );
                  },
                  child: const Icon(Icons.aspect_ratio),
                  tooltip: 'Show Responsive Demo',
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'admin_login',
                  onPressed: () {
                    // Check if already logged in
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboard(),
                        ),
                      );
                    } else {
                      // Not logged in, go to Auth Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthScreen(
                            initialRole: 'vendor',
                            onAuthSuccess: () {
                              // After successful login, replace with Admin Dashboard
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin Login',
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'manage_data_btn',
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.settings_applications),
                  label: const Text('Manage Test Data'),
                  onPressed: () {
                    DataSeederUtil.showManagerDialog(context);
                  },
                ),
              ],
            ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 600;
                final isDesktop = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero Section
                      _buildHeroSection(context, isWideScreen, isDesktop),

                      // Food Outlets Section
                      _buildFoodOutletsSection(context, isWideScreen, isDesktop),

                      // Features Section
                      _buildFeaturesSection(context, isWideScreen, isDesktop),

                      // How It Works Section
                      _buildHowItWorksSection(context, isWideScreen, isDesktop),

                      // CTA Section
                      _buildCTASection(context, isWideScreen),
                      
                      const SizedBox(height: 100), // padding for the floating widget
                    ],
                  ),
                );
              },
            ),
            
            // The Live Queue Widget pinned to the bottom of the screen
            const Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: LiveQueueWidget(),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'Signed in user',
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    bool isWideScreen,
    bool isDesktop,
  ) {
    final logoSize = isDesktop ? 80.0 : (isWideScreen ? 70.0 : 60.0);
    final titleSize = isDesktop ? 56.0 : (isWideScreen ? 52.0 : 42.0);
    final taglineSize = isDesktop ? 22.0 : (isWideScreen ? 20.0 : 16.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : (isWideScreen ? 32 : 20),
        vertical: isDesktop ? 64 : (isWideScreen ? 48 : 36),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
        ),
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left side - Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qless',
                        style: GoogleFonts.righteous(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Skip the Line, Enjoy the Food',
                        style: GoogleFonts.poppins(
                          fontSize: taglineSize,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order from your favorite street food vendors with zero wait time',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildHeroButtons(context, isWideScreen),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Right side - Animated Food Hero
                AnimatedFoodHero(size: logoSize),
              ],
            )
          : Column(
              children: [
                // Animated Food Hero fallback
                SizedBox(height: isWideScreen ? 20 : 10),
                AnimatedFoodHero(size: logoSize),
                SizedBox(height: isWideScreen ? 48 : 40),

                // App Name
                Text(
                  'Qless',
                  style: GoogleFonts.righteous(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Skip the Line, Enjoy the Food',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: taglineSize,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: isWideScreen ? 32 : 24),

                _buildHeroButtons(context, isWideScreen),
              ],
            ),
    );
  }

  Widget _buildHeroButtons(BuildContext context, bool isWideScreen) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Track Order Button
        OutlinedButton(
          onPressed: () {
            _showTrackOrderDialog(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 32 : 24,
              vertical: isWideScreen ? 18 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: isWideScreen ? 24 : 20),
              SizedBox(width: isWideScreen ? 12 : 8),
              Text(
                'Track Order',
                style: TextStyle(
                  fontSize: isWideScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // My Orders Button (only if authenticated)
        if (isAuthenticatedUser)
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 32 : 24,
                vertical: isWideScreen ? 18 : 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, size: isWideScreen ? 24 : 20),
                SizedBox(width: isWideScreen ? 12 : 8),
                Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: isWideScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFoodOutletsSection(
    BuildContext context,
    bool isWideScreen,
    bool isDesktop,
  ) {
    final crossAxisCount = isDesktop ? 3 : (isWideScreen ? 2 : 1);
    final childAspectRatio = isDesktop ? 1.4 : (isWideScreen ? 1.5 : 2.2);

    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      child: Column(
        children: [
          Text(
            'Available Shops',
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Live vendor data from Firebase',
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isWideScreen ? 32 : 24),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService.instance.vendorsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: const FoodLoadingIndicator(size: 40),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No shops available yet.',
                    style: GoogleFonts.poppins(color: Colors.grey.shade700),
                  ),
                );
              }

              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final shopName = (data['shopName'] as String?)?.trim().isNotEmpty == true
                          ? (data['shopName'] as String).trim()
                          : ((data['ownerName'] as String?)?.trim().isNotEmpty == true
                              ? (data['ownerName'] as String).trim()
                              : 'Vendor');
                      final subtitle = (data['description'] as String?)?.trim().isNotEmpty == true
                          ? (data['description'] as String).trim()
                          : 'Tap to browse items';
                      final isOpen = data['isOpen'] as bool? ?? true;
                      final imageUrl = (data['imageUrl'] as String?) ?? '';

                      return _buildOutletCard(
                        context,
                        vendorId: docs[index].id,
                        shopName: shopName,
                        subtitle: subtitle,
                        isOpen: isOpen,
                        colorIndex: index,
                        isWideScreen: isWideScreen,
                        imageUrl: imageUrl,
                      );
                    },
                  ),
                  SizedBox(height: isWideScreen ? 32 : 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AvailableShopsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 24,
                          vertical: isWideScreen ? 18 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store, size: isWideScreen ? 24 : 20),
                          SizedBox(width: isWideScreen ? 12 : 8),
                          Text(
                            'Browse All Shops',
                            style: GoogleFonts.poppins(
                              fontSize: isWideScreen ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutletCard(
    BuildContext context,
    {
    required String vendorId,
    required String shopName,
    required String subtitle,
    required bool isOpen,
    required int colorIndex,
    required bool isWideScreen,
    required String imageUrl,
  }
  ) {
    const defaultImageUrls = [
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1585521537745-68823e6ce39f?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1570080166338-1c2e4a0db3e3?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1564236052573-4ca76fc3e810?w=800&h=600&fit=crop',
    ];

    final rating = 4.0 + (colorIndex * 0.2) % 1.5;
    final orderedCount = 2500 + (colorIndex * 1000);
    final backgroundImage = imageUrl.isNotEmpty ? imageUrl : defaultImageUrls[colorIndex % defaultImageUrls.length];

    return GestureDetector(
      onTap: isOpen
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopMenuScreen(
                    vendorId: vendorId,
                    shopName: shopName,
                  ),
                ),
              );
            }
          : null,
      child: Opacity(
        opacity: isOpen ? 1.0 : 0.5,
        child: Container(
          height: isWideScreen ? 320 : 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  backgroundImage,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, trace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom info panel
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shopName,
                            style: GoogleFonts.poppins(
                              fontSize: isWideScreen ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Closed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF32A852),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(2),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$orderedCount ordered',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isWideScreen,
    bool isDesktop,
  ) {
    final features = [
      {
        'icon': Icons.speed,
        'title': 'No More Waiting',
        'description': 'Get a digital token and skip the physical queue',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Live Updates',
        'description': 'Know exactly when your order is ready for pickup',
      },
      {
        'icon': Icons.menu_book,
        'title': 'Browse Menu',
        'description': 'See live menu with real-time availability',
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Order History',
        'description': 'Keep track of all your past orders',
      },
    ];

    final crossAxisCount = isDesktop ? 4 : (isWideScreen ? 2 : 2);
    final childAspectRatio = isDesktop ? 0.9 : (isWideScreen ? 0.95 : 0.85);

    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'Why Choose Qless?',
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your favorite street food, without the hassle',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isWideScreen ? 40 : 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isWideScreen ? 20 : 12,
              mainAxisSpacing: isWideScreen ? 20 : 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureCard(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
                isWideScreen: isWideScreen,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isWideScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isWideScreen ? 14 : 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isWideScreen ? 36 : 28,
              color: Colors.orange.shade600,
            ),
          ),
          SizedBox(height: isWideScreen ? 18 : 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isWideScreen ? 10 : 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 14 : 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(
    BuildContext context,
    bool isWideScreen,
    bool isDesktop,
  ) {
    final steps = [
      {
        'number': '1',
        'title': 'Browse Menu',
        'description': 'Check out available items and prices',
        'icon': Icons.restaurant_menu,
      },
      {
        'number': '2',
        'title': 'Place Order',
        'description': 'Select items and confirm your order',
        'icon': Icons.shopping_cart,
      },
      {
        'number': '3',
        'title': 'Get Token',
        'description': 'Receive your unique queue token',
        'icon': Icons.confirmation_number,
      },
      {
        'number': '4',
        'title': 'Pick Up',
        'description': 'Collect when your token is called',
        'icon': Icons.check_circle,
      },
    ];

    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simple steps to delicious food',
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isWideScreen ? 40 : 28),

          if (isDesktop)
            // Horizontal layout for desktop
            Row(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Expanded(
                  child: _buildStepItemHorizontal(
                    number: step['number'] as String,
                    title: step['title'] as String,
                    description: step['description'] as String,
                    icon: step['icon'] as IconData,
                    isLast: index == steps.length - 1,
                    isWideScreen: isWideScreen,
                  ),
                );
              }).toList(),
            )
          else
            // Vertical layout for mobile/tablet
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return _buildStepItemVertical(
                number: step['number'] as String,
                title: step['title'] as String,
                description: step['description'] as String,
                icon: step['icon'] as IconData,
                isLast: index == steps.length - 1,
                isWideScreen: isWideScreen,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStepItemHorizontal({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required bool isLast,
    required bool isWideScreen,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 3, color: Colors.orange.shade200),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 3,
                color: isLast ? Colors.transparent : Colors.orange.shade200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.orange.shade600),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItemVertical({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required bool isLast,
    required bool isWideScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: isWideScreen ? 52 : 44,
              height: isWideScreen ? 52 : 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWideScreen ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: isWideScreen ? 70 : 56,
                color: Colors.orange.shade200,
              ),
          ],
        ),
        SizedBox(width: isWideScreen ? 20 : 14),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              bottom: isLast ? 0 : (isWideScreen ? 28 : 20),
            ),
            padding: EdgeInsets.all(isWideScreen ? 18 : 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: isWideScreen ? 40 : 32,
                  color: Colors.orange.shade600,
                ),
                SizedBox(width: isWideScreen ? 18 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isWideScreen ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 6 : 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isWideScreen ? 15 : 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context, bool isWideScreen) {
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 48 : 28),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Icon(
            Icons.local_dining,
            size: isWideScreen ? 72 : 56,
            color: Colors.orange.shade600,
          ),
          SizedBox(height: isWideScreen ? 20 : 14),
          Text(
            'Ready to Order?',
            style: TextStyle(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Delicious street food is just a tap away',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isWideScreen ? 32 : 24),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 500 : double.infinity,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to menu
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isWideScreen ? 18 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book),
                        const SizedBox(width: 8),
                        Text(
                          'View Menu',
                          style: TextStyle(
                            fontSize: isWideScreen ? 17 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showTrackOrderDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(
                        vertical: isWideScreen ? 18 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        Text(
                          'Track Order',
                          style: TextStyle(
                            fontSize: isWideScreen ? 17 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // My Orders Button (only if authenticated)
          if (isAuthenticatedUser) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 500 : double.infinity,
              ),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(
                    vertical: isWideScreen ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Colors.deepOrange,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 8),
                    Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: isWideScreen ? 17 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: isWideScreen ? 40 : 28),

          // Footer
          Text(
            '© 2026 Qless by Team codynamics',
            style: TextStyle(
              fontSize: isWideScreen ? 14 : 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _findOrderByToken(String tokenInput) async {
    String searchToken = tokenInput.toUpperCase().trim();
    debugPrint('🔍 Searching for token: "$searchToken"');

    try {
      // SOLUTION: Instead of using .where() which needs indexes,
      // fetch user's orders directly and search locally
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ User not logged in');
        return null;
      }

      // Get ALL orders for this user
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      debugPrint('📊 Found ${snapshot.docs.length} total orders for user');

      // Search through them locally
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tokenInDB = data['token']?.toString() ?? '';
        final status = data['status'] ?? 'unknown';
        
        debugPrint('  Comparing: "$tokenInDB" vs "$searchToken"');

        // Token exact match
        if (tokenInDB.toUpperCase() == searchToken) {
          debugPrint('✅ EXACT MATCH! Token: "$tokenInDB", Order ID: ${doc.id}');
          return doc.id;
        }
        
        // Try matching just the digits (without T)
        final tokenDigits = tokenInDB.replaceAll(RegExp(r'[^0-9]'), '');
        final searchDigits = searchToken.replaceAll(RegExp(r'[^0-9]'), '');
        
        if (tokenDigits == searchDigits && tokenDigits.isNotEmpty) {
          debugPrint('✅ DIGIT MATCH! Token: "$tokenInDB", Order ID: ${doc.id}');
          return doc.id;
        }
      }

      debugPrint('❌ No matching token found in user orders');
      debugPrint('💡 Orders with tokens:');
      for (var doc in snapshot.docs) {
        final tokenInDB = doc.data()['token'] ?? 'N/A';
        debugPrint('  - "$tokenInDB"');
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error searching orders: $e');
      return null;
    }
  }

  void _showTrackOrderDialog(BuildContext context) {
    final tokenController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.confirmation_number, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Track Your Order'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your token number to check order status',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tokenController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  maxLength: 7,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9Tt]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'T000001',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade600,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Or tap a recent order:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  // Simplified: Fetch all user orders without orderBy (requires composite index)
                  // Filter and sort locally instead
                  future: FirebaseFirestore.instance
                      .collection('orders')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      // Filter for active status and sort locally
                      final activeOrders = snapshot.data!.docs
                          .where((doc) {
                            final status = doc['status'];
                            return status == 'pending' || status == 'cooking' || status == 'ready';
                          })
                          .toList();
                      
                      // Sort by createdAt descending
                      activeOrders.sort((a, b) {
                        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                        return bTime.compareTo(aTime);
                      });
                      
                      // Limit to 3
                      final recentOrders = activeOrders.take(3).toList();
                      
                      if (recentOrders.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recentOrders.map((doc) {
                          final token = doc['token']?.toString() ?? 'N/A';
                          final status = doc['status'] ?? 'unknown';
                          return GestureDetector(
                            onTap: () {
                              tokenController.text = token;
                              setState(() {}); // Update to show selected token
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepOrange),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.deepOrange.withValues(alpha: 0.1),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    token,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final input = tokenController.text.trim();
                      if (input.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a token number')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      final orderId = await _findOrderByToken(input);

                      if (!dialogContext.mounted) return;

                      setState(() => isLoading = false);

                      if (orderId != null) {
                        Navigator.pop(dialogContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: orderId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order not found. You searched for: "$input"'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Track', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

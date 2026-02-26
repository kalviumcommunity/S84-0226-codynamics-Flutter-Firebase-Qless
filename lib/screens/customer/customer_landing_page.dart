import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qless/screens/auth/auth_screen.dart';
import 'package:qless/screens/admin/admin_dashboard.dart';
import 'package:qless/screens/responsive_home.dart';

class CustomerLandingPage extends StatelessWidget {
  const CustomerLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              } else {
                // Not logged in, go to Auth Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onAuthSuccess: () {
                        // After successful login, replace with Admin Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminDashboard()),
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
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildHeroSection(BuildContext context, bool isWideScreen, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade600,
          ],
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
                // Right side - Logo
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: logoSize,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Logo
                Container(
                  padding: EdgeInsets.all(isWideScreen ? 24 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: logoSize,
                    color: Colors.orange.shade600,
                  ),
                ),
                SizedBox(height: isWideScreen ? 28 : 20),
                
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
        // Main CTA Button
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to menu/order page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepOrange,
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 48 : 32,
              vertical: isWideScreen ? 18 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fastfood, size: isWideScreen ? 24 : 20),
              SizedBox(width: isWideScreen ? 12 : 8),
              Text(
                'Order Now',
                style: TextStyle(
                  fontSize: isWideScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
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
      ],
    );
  }

  Widget _buildFoodOutletsSection(BuildContext context, bool isWideScreen, bool isDesktop) {
    final crossAxisCount = isDesktop ? 3 : (isWideScreen ? 2 : 1);
    final childAspectRatio = isDesktop ? 1.4 : (isWideScreen ? 1.5 : 2.2);
    
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      child: Column(
        children: [
          Text(
            'Popular Food Outlets',
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover delicious street food near you',
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isWideScreen ? 32 : 24),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _foodOutlets.length,
            itemBuilder: (context, index) {
              final outlet = _foodOutlets[index];
              return _buildOutletCard(context, outlet, isWideScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutletCard(BuildContext context, Map<String, dynamic> outlet, bool isWideScreen) {
    final Color outletColor = outlet['color'] as Color;
    final bool isOpen = outlet['isOpen'] as bool;
    
    return GestureDetector(
      onTap: isOpen ? () {
        // TODO: Navigate to outlet menu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${outlet['name']}...'),
            backgroundColor: outletColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } : null,
      child: Container(
        padding: EdgeInsets.all(isWideScreen ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isOpen ? Colors.grey.shade100 : Colors.grey.shade300,
          ),
        ),
        child: Opacity(
          opacity: isOpen ? 1.0 : 0.6,
          child: Row(
            children: [
              // Outlet Icon
              Container(
                padding: EdgeInsets.all(isWideScreen ? 16 : 12),
                decoration: BoxDecoration(
                  color: outletColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  outlet['icon'] as IconData,
                  size: isWideScreen ? 36 : 28,
                  color: outletColor,
                ),
              ),
              SizedBox(width: isWideScreen ? 16 : 12),
              
              // Outlet Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            outlet['name'] as String,
                            style: TextStyle(
                              fontSize: isWideScreen ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(height: 4),
                    Text(
                      outlet['cuisine'] as String,
                      style: TextStyle(
                        fontSize: isWideScreen ? 14 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      outlet['speciality'] as String,
                      style: TextStyle(
                        fontSize: isWideScreen ? 13 : 11,
                        color: outletColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${outlet['rating']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          outlet['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              if (isOpen)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isWideScreen, bool isDesktop) {
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

  Widget _buildHowItWorksSection(BuildContext context, bool isWideScreen, bool isDesktop) {
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
              child: Container(
                height: 3,
                color: Colors.orange.shade200,
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade600,
                  ],
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
              Icon(
                icon,
                size: 32,
                color: Colors.orange.shade600,
              ),
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
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade600,
                  ],
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
            margin: EdgeInsets.only(bottom: isLast ? 0 : (isWideScreen ? 28 : 20)),
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
            constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
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
                      padding: EdgeInsets.symmetric(vertical: isWideScreen ? 18 : 14),
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
                      padding: EdgeInsets.symmetric(vertical: isWideScreen ? 18 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.deepOrange, width: 2),
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

  void _showTrackOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.confirmation_number, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Track Your Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your token number to check order status',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              maxLength: 3,
              decoration: InputDecoration(
                hintText: '000',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement order tracking
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Track', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

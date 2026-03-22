import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qless/screens/auth/auth_screen.dart';
import 'package:qless/screens/admin/admin_dashboard.dart';
import 'package:qless/screens/responsive_home.dart';
<<<<<<< HEAD
import 'package:qless/screens/customer/vendor_menu_screen.dart';
=======
import 'package:qless/screens/customer/shop_menu_screen.dart';
import 'package:qless/services/firestore_service.dart';
import 'package:qless/screens/customer/data_seeder_util.dart';

import 'package:qless/screens/customer/user_dashboard_screen.dart';
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0

class CustomerLandingPage extends StatefulWidget {
  final bool isAuthenticatedUser;

  const CustomerLandingPage({
    super.key,
    this.isAuthenticatedUser = false,
  });

<<<<<<< HEAD
  @override
  State<CustomerLandingPage> createState() => _CustomerLandingPageState();
}

class _CustomerLandingPageState extends State<CustomerLandingPage> {
  int _selectedIndex = 0;

=======
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
  @override
  Widget build(BuildContext context) {
    // Define pages for each tab
    final List<Widget> pages = [
      _buildHomePage(context),
      _buildOrdersPage(context),
      _buildNotificationsPage(context),
      _buildProfilePage(context),
    ];

    return Scaffold(
      appBar: widget.isAuthenticatedUser
          ? AppBar(
              title: Text(
                _selectedIndex == 0
                    ? 'Qless'
                    : _selectedIndex == 1
                        ? 'My Orders'
                        : _selectedIndex == 2
                            ? 'Notifications'
                            : 'Profile',
                style: GoogleFonts.righteous(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                if (_selectedIndex == 0)
                  IconButton(
                    onPressed: () => _showProfileSheet(context),
                    icon: const Icon(Icons.account_circle_outlined),
                    tooltip: 'Profile',
                  ),
              ],
            )
          : null,
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(context, isWideScreen, isDesktop),

              // Approved Vendors Section
              _buildApprovedVendorsSection(context, isWideScreen, isDesktop),

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
    );
  }

  Widget _buildOrdersPage(BuildContext context) {
    if (!widget.isAuthenticatedUser) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to view orders',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onAuthSuccess: () {
                        // Navigation handled by main.dart
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
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
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            final status = order['status'] as String? ?? 'pending';
            final total = (order['total'] as num?)?.toDouble() ?? 0.0;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepOrange.withOpacity(0.2),
                  child: const Icon(Icons.receipt, color: Colors.deepOrange),
                ),
                title: Text(
                  'Order #${orderId.substring(0, 8)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Status: ${status.toUpperCase()}'),
                trailing: Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsPage(BuildContext context) {
    if (!widget.isAuthenticatedUser) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to view notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onAuthSuccess: () {
                        // Navigation handled by main.dart
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    if (!widget.isAuthenticatedUser) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Guest Mode',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your profile',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onAuthSuccess: () {
                        // Navigation handled by main.dart
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepOrange.shade100,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
            );
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

  Widget _buildApprovedVendorsSection(
    BuildContext context,
    bool isWideScreen,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
<<<<<<< HEAD
            'Available Vendors',
=======
            'Available Shops',
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
            style: GoogleFonts.poppins(
              fontSize: isWideScreen ? 32 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
<<<<<<< HEAD
            'Browse food from approved vendors',
=======
            'Live vendor data from Firebase',
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
            style: GoogleFonts.inter(
              fontSize: isWideScreen ? 18 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isWideScreen ? 32 : 24),

<<<<<<< HEAD
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'vendor')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vendors available yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
=======
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService.instance.vendorsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
                  ),
                );
              }

<<<<<<< HEAD
              // Filter approved vendors in the app
              final approvedVendors = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] as String? ?? 'pending';
                return status == 'approved';
              }).toList();

              if (approvedVendors.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vendors available yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
=======
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No shops available yet.',
                    style: GoogleFonts.poppins(color: Colors.grey.shade700),
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
                  ),
                );
              }

<<<<<<< HEAD
              final crossAxisCount = isDesktop ? 3 : (isWideScreen ? 2 : 1);

=======
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
<<<<<<< HEAD
                  childAspectRatio: isDesktop ? 1.1 : (isWideScreen ? 1.2 : 1.5),
                ),
                itemCount: approvedVendors.length,
                itemBuilder: (context, index) {
                  final vendorDoc = approvedVendors[index];
                  final vendor = vendorDoc.data() as Map<String, dynamic>;
                  final vendorId = vendorDoc.id; // Get document ID
                  return _buildVendorCard(context, vendor, vendorId, isWideScreen);
=======
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
                  final isOpen = data['isActive'] as bool? ?? true;

                  return _buildOutletCard(
                    context,
                    vendorId: docs[index].id,
                    shopName: shopName,
                    subtitle: subtitle,
                    isOpen: isOpen,
                    colorIndex: index,
                    isWideScreen: isWideScreen,
                  );
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(
    BuildContext context,
<<<<<<< HEAD
    Map<String, dynamic> vendor,
    String vendorId,
    bool isWideScreen,
  ) {
    final shopName = vendor['shopName'] as String? ?? 'Unknown Shop';
    final description = vendor['description'] as String? ?? 'No description';
    final isOpen = vendor['isOpen'] as bool? ?? false;
    final imageUrl = vendor['imageUrl'] as String?;

    return GestureDetector(
      onTap: () {
        if (!isOpen) {
          // Show closed message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$shopName is currently closed',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (vendorId.isNotEmpty) {
          // Navigate to vendor menu
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorMenuScreen(
                vendorId: vendorId,
                shopName: shopName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open vendor menu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vendor Image or Icon
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade300,
                          Colors.deepOrange.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                Icons.store,
                                size: 50,
                                color: Colors.deepOrange.shade700,
=======
    {
    required String vendorId,
    required String shopName,
    required String subtitle,
    required bool isOpen,
    required int colorIndex,
    required bool isWideScreen,
  }
  ) {
    const colors = [
      Colors.deepOrange,
      Colors.teal,
      Colors.indigo,
      Colors.green,
      Colors.brown,
      Colors.pink,
    ];
    const icons = [
      Icons.storefront,
      Icons.local_dining,
      Icons.ramen_dining,
      Icons.local_cafe,
      Icons.lunch_dining,
      Icons.restaurant,
    ];

    final outletColor = colors[colorIndex % colors.length];
    final outletIcon = icons[colorIndex % icons.length];

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
                  outletIcon,
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
                            shopName,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.store,
                              size: 50,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
<<<<<<< HEAD
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isOpen ? 'OPEN' : 'CLOSED',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
=======
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOpen ? 'Open now' : 'Currently unavailable',
                      style: TextStyle(
                        fontSize: isWideScreen ? 14 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isWideScreen ? 13 : 11,
                        color: outletColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
>>>>>>> 20727ec32dfcc65a13dccb622afc3a2e414925a0
              ),
            ),
            // Vendor Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shopName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? 'Delicious food awaits!' : description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  borderSide: BorderSide(
                    color: Colors.orange.shade600,
                    width: 2,
                  ),
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

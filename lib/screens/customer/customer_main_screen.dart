import 'package:flutter/material.dart';
import 'package:qless/widgets/floating_nav_bar.dart';
import 'customer_landing_page.dart';
import 'enhanced_user_profile_screen.dart';
import 'my_orders_screen.dart';
import 'available_shops_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CustomerLandingPage(isAuthenticatedUser: true), // Home page
    AvailableShopsScreen(), // Browse available shops
    MyOrdersScreen(), // Order history
    EnhancedUserProfileScreen(), // User profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        items: const [
          FloatingNavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          FloatingNavBarItem(
            icon: Icons.store_outlined,
            selectedIcon: Icons.store,
            label: 'Shops',
          ),
          FloatingNavBarItem(
            icon: Icons.receipt_outlined,
            selectedIcon: Icons.receipt,
            label: 'Orders',
          ),
          FloatingNavBarItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

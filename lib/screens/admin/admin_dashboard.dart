import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/screens/admin/live_orders_screen.dart';
import 'package:qless/screens/admin/menu_items_screen.dart';
import 'package:qless/screens/admin/vendor_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final newUnreadCount = snapshot.docs.length;
        
        // Show snackbar if there's a new notification
        if (newUnreadCount > _unreadCount && _unreadCount > 0) {
          final latestNotif = snapshot.docs.first.data();
          final title = latestNotif['title'] as String? ?? 'New Notification';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.deepOrange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2; // Navigate to notifications tab
                  });
                },
              ),
            ),
          );
        }
        
        setState(() {
          _unreadCount = newUnreadCount;
        });
      }
    });
  }

  Future<void> _toggleStoreStatus(BuildContext context, bool isOpen) async {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (vendorId.isEmpty) return;

    try {
      // Check if this is the first time opening
      final vendorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .get();
      
      final hasOpenedBefore = vendorDoc.data()?['hasOpenedBefore'] as bool? ?? false;
      final isFirstTimeOpening = isOpen && !hasOpenedBefore;

      // Update vendor status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .update({
        'isOpen': isOpen,
        'lastStatusChange': FieldValue.serverTimestamp(),
        if (isFirstTimeOpening) 'hasOpenedBefore': true,
      });

      // Create notification for vendor
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': vendorId,
        'type': 'store_status',
        'title': isOpen ? 'Store is now Open' : 'Store is now Closed',
        'message': isOpen
            ? 'Your store is now live and visible to customers!'
            : 'Your store is now closed. Customers cannot see your menu.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // If opening store, notify super admin
      if (isOpen) {
        // Get vendor details
        final shopName = vendorDoc.data()?['shopName'] ?? 'A vendor';

        // Get all super admins
        final admins = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();

        // Send notification to each admin
        for (var admin in admins.docs) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': admin.id,
            'type': 'vendor_opened',
            'title': 'Vendor Opened Store',
            'message': '$shopName has opened their store and is now live!',
            'vendorId': vendorId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Show popup if first time opening
        if (isFirstTimeOpening && context.mounted) {
          _showFirstTimeLiveDialog(context, shopName);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOpen
                  ? 'Store is now open! Customers can see your menu.'
                  : 'Store is now closed.',
            ),
            backgroundColor: isOpen ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFirstTimeLiveDialog(BuildContext context, String shopName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 50,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🎉 Congratulations!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$shopName is now LIVE!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your store is now visible to customers. They can browse your menu and place orders.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Store is open',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Menu is visible to customers',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ready to receive orders',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Got it!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      // Navigation is handled automatically by StreamBuilder in main.dart
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages for each tab
    final List<Widget> pages = [
      _buildHomePage(context),
      const MenuItemsScreen(),
      _buildNotificationsPage(),
      const VendorProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Vendor Dashboard'
              : _selectedIndex == 1
                  ? 'Menu Items'
                  : _selectedIndex == 2
                      ? 'Notifications'
                      : 'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Are you sure you want to sign out?',
                    style: GoogleFonts.inter(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await FirebaseAuth.instance.signOut();
                // The StreamBuilder in main.dart will automatically redirect to AuthScreen
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_selectedIndex],
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: _unreadCount > 0
                ? Badge(
                    label: Text(_unreadCount.toString()),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Vendor! 👋',
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'All data is fetched live from Cloud Firestore.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          
          // Open/Closed Toggle Card
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(vendorId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final isOpen = data?['isOpen'] as bool? ?? false;
              
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                          color: isOpen ? Colors.green : Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store Status',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isOpen ? 'Currently Open' : 'Currently Closed',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isOpen,
                        onChanged: (value) => _toggleStoreStatus(context, value),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.receipt_long,
                  label: 'Live Orders',
                  description: 'Real-time stream via StreamBuilder',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LiveOrdersScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.restaurant_menu,
                  label: 'Menu Items',
                  description: 'Live menu via StreamBuilder',
                  color: Colors.green,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                _DashboardCard(
                  icon: Icons.person,
                  label: 'My Profile',
                  description: 'View and edit profile',
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                _DashboardCard(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  description: 'View all notifications',
                  color: Colors.purple,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const FoodLoadingIndicator(size: 40);
        }

        if (snapshot.hasError) {
          // If there's an error (like missing index), try without orderBy
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, fallbackSnapshot) {
              if (fallbackSnapshot.connectionState == ConnectionState.waiting) {
                return const FoodLoadingIndicator(size: 40);
              }

              if (fallbackSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!fallbackSnapshot.hasData || fallbackSnapshot.data!.docs.isEmpty) {
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
                      const SizedBox(height: 8),
                      Text(
                        'You\'ll see notifications here',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort manually since we can't use orderBy
              final notifications = fallbackSnapshot.data!.docs.toList();
              notifications.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

              return _buildNotificationsList(notifications);
            },
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                const SizedBox(height: 8),
                Text(
                  'You\'ll see notifications here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data!.docs;
        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildNotificationsList(List<QueryDocumentSnapshot> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        final data = notif.data() as Map<String, dynamic>;
        final title = data['title'] as String? ?? 'Notification';
        final message = data['message'] as String? ?? '';
        final isRead = data['isRead'] as bool? ?? false;
        final type = data['type'] as String? ?? 'general';
        final timestamp = data['createdAt'] as Timestamp?;

        return Card(
          elevation: isRead ? 1 : 3,
          color: isRead ? Colors.grey[100] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(type).withOpacity(0.2),
              child: Icon(
                _getNotificationIcon(type),
                color: _getNotificationColor(type),
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            onTap: () async {
              if (!isRead) {
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(notif.id)
                    .update({'isRead': true});
              }
            },
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'store_status':
        return Icons.store;
      case 'vendor_opened':
        return Icons.storefront;
      case 'order':
        return Icons.shopping_bag;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'store_status':
        return Colors.green;
      case 'vendor_opened':
        return Colors.blue;
      case 'order':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

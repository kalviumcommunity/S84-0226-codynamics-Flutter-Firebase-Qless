import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/screens/responsive_home.dart';
import 'package:qless/services/firestore_service.dart';
import 'shop_menu_screen.dart';
import 'user_profile_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  bool _isLoading = false;

  Future<void> _seedMockShops(BuildContext context) async {
    setState(() => _isLoading = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seeding shops...')),
    );
    try {
      final firestore = FirebaseFirestore.instance;
      final shops = [
        {'role': 'vendor', 'shopName': 'Spice Garden', 'ownerName': 'Chef Raj', 'description': 'Authentic Indian Biryani & Curries', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Dragon Wok', 'ownerName': 'Mei Lin', 'description': 'Delicious Chinese Noodles & Manchurian', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Burger Barn', 'ownerName': 'John Doe', 'description': 'American Burgers & Crispy Fries', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Chai & Snacks', 'ownerName': 'Amit', 'description': 'Hot Tea, Coffee & Fresh Samosas', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
        {'role': 'vendor', 'shopName': 'Pizza Planet', 'ownerName': 'Mario', 'description': 'Italian Pizzas & Pasta', 'isActive': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()},
      ];
      
      for (final shop in shops) {
        // Only adding mock auth UID to users collection
        final dummyUid = 'mock_${DateTime.now().millisecondsSinceEpoch}_${shop['shopName'].toString().replaceAll(" ", "")}';
        await firestore.collection('users').doc(dummyUid).set(shop);

        // Seed one dummy item per shop
        await firestore.collection('menu_items').add({
          'vendorId': dummyUid,
          'name': 'Signature ${shop['shopName'].toString().split(' ').last}',
          'description': 'Our famous bestselling item.',
          'price': 150.0,
          'category': 'Specials',
          'imageUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ 5 dummy shops added successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding: $e')),
        );
      }
    }
  }

  Future<void> _deleteMockShops(BuildContext context) async {
    setState(() => _isLoading = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting dummy shops...')),
    );
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Delete mock users
      final usersQuery = await firestore.collection('users').where('role', isEqualTo: 'vendor').get();
      int deletedUsers = 0;
      for (final doc in usersQuery.docs) {
        if (doc.id.startsWith('mock_')) {
          await doc.reference.delete();
          deletedUsers++;
        }
      }

      // Delete mock items
      final itemsQuery = await firestore.collection('menu_items').get();
      int deletedItems = 0;
      for (final doc in itemsQuery.docs) {
        final vendorId = doc.data()['vendorId'] as String?;
        if (vendorId != null && vendorId.startsWith('mock_')) {
          await doc.reference.delete();
          deletedItems++;
        }
      }

      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Deleted $deletedUsers shops and $deletedItems items')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  void _showDummyDataMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manage Dummy Data'),
        content: const Text('Add or remove test shops for development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: _isLoading ? null : () {
              Navigator.pop(ctx);
              _deleteMockShops(context);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete Dummy Shops', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () {
              Navigator.pop(ctx);
              _seedMockShops(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Dummy Shops'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Shops',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.storage),
              tooltip: 'Manage Dummy Data',
              onPressed: () => _showDummyDataMenu(context),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
            ),
          ]
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.instance.vendorsStream(),
        builder: (context, vendorsSnapshot) {
          if (vendorsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vendorsSnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading shops: ${vendorsSnapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final vendorDocs = vendorsSnapshot.data?.docs ?? [];
          final activeVendors = vendorDocs.where((doc) {
            final data = doc.data();
            return data['isActive'] as bool? ?? true;
          }).toList();

          if (activeVendors.isEmpty) {
             return Center(
                child: Text(
                  'No shops available right now.',
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                ),
              );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activeVendors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = activeVendors[index];
              final data = doc.data();
              
              final shopName = (data['shopName'] as String?)?.trim().isNotEmpty == true
                  ? (data['shopName'] as String).trim()
                  : ((data['ownerName'] as String?)?.trim().isNotEmpty == true
                      ? (data['ownerName'] as String).trim()
                      : 'Vendor');
              
              final description = data['description'] as String? ?? 'Tap to view menu';
              final imageUrl = data['imageUrl'] as String? ?? '';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopMenuScreen(
                          vendorId: doc.id,
                          shopName: shopName,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            imageUrl,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, trace) => _buildPlaceholder(),
                          ),
                        )
                      else
                        _buildPlaceholder(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3E0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(Icons.storefront, size: 56, color: Colors.deepOrange),
      ),
    );
  }
}


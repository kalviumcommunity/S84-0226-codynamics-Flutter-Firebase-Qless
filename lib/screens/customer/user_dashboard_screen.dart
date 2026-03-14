import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/screens/responsive_home.dart';
import 'package:qless/services/firestore_service.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'user_responsive_demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResponsiveHome()),
              );
            },
            child: const Icon(Icons.aspect_ratio),
            tooltip: 'Show Responsive Demo',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Qless',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () {
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
                            currentUser?.email ?? 'Signed in user',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                            ),
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
            },
          ),
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
                'Unable to load vendors right now.',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final vendorDocs = vendorsSnapshot.data?.docs ?? [];
          final vendorById = <String, String>{};

          for (final doc in vendorDocs) {
            final data = doc.data();
            final displayName = (data['shopName'] as String?)?.trim().isNotEmpty == true
                ? (data['shopName'] as String).trim()
                : ((data['ownerName'] as String?)?.trim().isNotEmpty == true
                    ? (data['ownerName'] as String).trim()
                    : 'Vendor');
            vendorById[doc.id] = displayName;
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService.instance.menuItemsStream(),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productsSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load products right now.',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final products = productsSnapshot.data?.docs ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome${currentUser?.email != null ? ', ${currentUser!.email}' : ''} 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse all vendors and their products.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Home Options',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _QuickOptionChip(
                          icon: Icons.fastfood,
                          label: 'Food Outlets',
                          onTap: () {
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                const SnackBar(content: Text('Scroll below for vendors and products.')),
                              );
                          },
                        ),
                        _QuickOptionChip(
                          icon: Icons.aspect_ratio,
                          label: 'Responsive Demo',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ResponsiveHome()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Vendors',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vendorDocs.isEmpty)
                      Text(
                        'No vendors found.',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: vendorDocs.map((doc) {
                          final vendorName = vendorById[doc.id] ?? 'Vendor';
                          return Chip(
                            label: Text(
                              vendorName,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            avatar: const Icon(Icons.store_mall_directory, size: 18),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Products',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (products.isEmpty)
                      Text(
                        'No products available yet.',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final productData = products[index].data();
                          final productName = productData['name'] as String? ?? 'Unnamed Product';
                          final category = productData['category'] as String? ?? 'Uncategorized';
                          final price = (productData['price'] as num?)?.toDouble() ?? 0;
                          final isAvailable = productData['isAvailable'] as bool? ?? true;
                          final vendorId = productData['vendorId'] as String? ?? '';
                          final vendorName = vendorById[vendorId] ?? 'Unknown Vendor';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAvailable
                                    ? Colors.deepOrange.shade100
                                    : Colors.grey.shade200,
                                child: Icon(
                                  Icons.fastfood,
                                  color: isAvailable ? Colors.deepOrange : Colors.grey,
                                ),
                              ),
                              title: Text(
                                productName,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '$vendorName • $category',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              trailing: Text(
                                '₹${price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuickOptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickOptionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      onPressed: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/vendor_provider.dart';

/// Analytics dashboard showing vendor statistics
class VendorAnalyticsScreen extends StatelessWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: VendorProvider().getVendorAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading analytics',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final totalOrders = data['totalOrders'] ?? 0;
          final totalRevenue = data['totalRevenue'] ?? 0.0;
          final todayOrders = data['todayOrders'] ?? 0;
          final mostOrderedItem = data['mostOrderedItem'] ?? 'N/A';
          final mostOrderedCount = data['mostOrderedCount'] ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger rebuild by returning future
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.receipt_long,
                        label: 'Total Orders',
                        value: totalOrders.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.currency_rupee,
                        label: 'Total Revenue',
                        value: '₹${totalRevenue.toStringAsFixed(0)}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.today,
                        label: 'Today\'s Orders',
                        value: todayOrders.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        label: 'Avg Order Value',
                        value: totalOrders > 0
                            ? '₹${(totalRevenue / totalOrders).toStringAsFixed(0)}'
                            : '₹0',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Most ordered item
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              'Most Ordered Item',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mostOrderedItem,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered $mostOrderedCount times',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recent activity
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const _RecentOrdersList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrdersList extends StatelessWidget {
  const _RecentOrdersList();

  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No recent orders',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            final token = data['tokenNumber'] ?? 0;
            final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('#$token'),
                ),
                title: Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

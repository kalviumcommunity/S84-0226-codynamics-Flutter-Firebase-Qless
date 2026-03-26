import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/models/user_model.dart';

class AllVendorsScreen extends StatelessWidget {
  const AllVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Vendors',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'vendor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FoodLoadingIndicator(size: 40);
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vendors found'));
          }

          final vendors = snapshot.data!.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();

          // Group vendors by status
          final approved = vendors.where((v) => v.vendorStatus == VendorStatus.approved).toList();
          final pending = vendors.where((v) => v.vendorStatus == VendorStatus.pending).toList();
          final rejected = vendors.where((v) => v.vendorStatus == VendorStatus.rejected).toList();
          final blocked = vendors.where((v) => v.vendorStatus == VendorStatus.blocked).toList();

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: 'Approved (${approved.length})'),
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'Rejected (${rejected.length})'),
                    Tab(text: 'Blocked (${blocked.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildVendorList(approved),
                      _buildVendorList(pending),
                      _buildVendorList(rejected),
                      _buildVendorList(blocked),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorList(List<UserModel> vendors) {
    if (vendors.isEmpty) {
      return const Center(child: Text('No vendors in this category'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vendors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return _buildVendorCard(vendor);
      },
    );
  }

  Widget _buildVendorCard(UserModel vendor) {
    final statusColor = _getStatusColor(vendor.vendorStatus);
    final isOpen = vendor.isActive;

    return Card(
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    Icons.store,
                    color: statusColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.shopName ?? 'Unknown Shop',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Owner: ${vendor.ownerName ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vendor.vendorStatus?.name.toUpperCase() ?? 'UNKNOWN',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vendor.vendorStatus == VendorStatus.approved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'OPEN' : 'CLOSED',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  vendor.email,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
            if (vendor.phone != null && vendor.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    vendor.phone!,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(VendorStatus? status) {
    switch (status) {
      case VendorStatus.approved:
        return Colors.green;
      case VendorStatus.pending:
        return Colors.orange;
      case VendorStatus.rejected:
        return Colors.red;
      case VendorStatus.blocked:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

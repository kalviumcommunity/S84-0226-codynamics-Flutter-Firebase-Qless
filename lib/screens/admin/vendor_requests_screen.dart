import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/services/admin_service.dart';
import 'package:qless/models/user_model.dart';

/// Screen to review and approve/reject vendor requests
class VendorRequestsScreen extends StatefulWidget {
  const VendorRequestsScreen({super.key});

  @override
  State<VendorRequestsScreen> createState() => _VendorRequestsScreenState();
}

class _VendorRequestsScreenState extends State<VendorRequestsScreen> {
  String _selectedFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Requests',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'pending',
                  label: Text('Pending'),
                  icon: Icon(Icons.pending_actions),
                ),
                ButtonSegment(
                  value: 'approved',
                  label: Text('Approved'),
                  icon: Icon(Icons.check_circle),
                ),
                ButtonSegment(
                  value: 'rejected',
                  label: Text('Rejected'),
                  icon: Icon(Icons.cancel),
                ),
                ButtonSegment(
                  value: 'blocked',
                  label: Text('Blocked'),
                  icon: Icon(Icons.block),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedFilter = value.first;
                });
              },
              showSelectedIcon: false,
            ),
          ),

          // Vendor List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: AdminService.instance.vendorRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const FoodLoadingIndicator(size: 40);
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No vendor requests found'),
                  );
                }

                final vendors = snapshot.data!.docs
                    .map((doc) => UserModel.fromFirestore(doc))
                    .where((vendor) => vendor.vendorStatus?.name == _selectedFilter)
                    .toList();

                if (vendors.isEmpty) {
                  return Center(
                    child: Text('No $_selectedFilter vendors'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return _buildVendorCard(vendor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(UserModel vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text('Owner: ${vendor.ownerName ?? 'N/A'}'),
            Text('Email: ${vendor.email}'),
            Text('Status: ${vendor.vendorStatus?.name ?? 'N/A'}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vendor.vendorStatus == VendorStatus.pending) ...[
                  TextButton.icon(
                    onPressed: () => _rejectVendor(vendor),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approveVendor(vendor),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ],
                if (vendor.vendorStatus == VendorStatus.approved)
                  TextButton.icon(
                    onPressed: () => _blockVendor(vendor),
                    icon: const Icon(Icons.block, color: Colors.red),
                    label: const Text('Block'),
                  ),
                if (vendor.vendorStatus == VendorStatus.blocked)
                  ElevatedButton.icon(
                    onPressed: () => _unblockVendor(vendor),
                    icon: const Icon(Icons.check),
                    label: const Text('Unblock'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveVendor(UserModel vendor) async {
    await AdminService.instance.approveVendor(vendor.uid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor approved')),
      );
    }
  }

  Future<void> _rejectVendor(UserModel vendor) async {
    await AdminService.instance.rejectVendor(
      vendor.uid,
      reason: 'Rejected by admin',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor rejected')),
      );
    }
  }

  Future<void> _blockVendor(UserModel vendor) async {
    await AdminService.instance.blockVendor(
      vendor.uid,
      reason: 'Blocked by admin',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor blocked')),
      );
    }
  }

  Future<void> _unblockVendor(UserModel vendor) async {
    await AdminService.instance.unblockVendor(vendor.uid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor unblocked')),
      );
    }
  }
}

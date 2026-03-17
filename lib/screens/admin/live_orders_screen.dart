import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays live orders from the Firestore `orders` collection in real-time.
/// Uses a [StreamBuilder] so any vendor update reflects instantly.
class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({super.key});

  @override
  State<LiveOrdersScreen> createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> {
  // Toggle: show all orders or only pending orders
  bool _pendingOnly = false;

  static const _statusColors = {
    'pending': Colors.orange,
    'cooking': Colors.blue,
    'ready': Colors.green,
    'completed': Colors.grey,
  };

  static const _statusIcons = {
    'pending': Icons.hourglass_empty,
    'cooking': Icons.soup_kitchen,
    'ready': Icons.check_circle_outline,
    'completed': Icons.done_all,
  };

  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    final stream = _buildQuery(vendorId, _pendingOnly);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text('Pending only',
                  style: GoogleFonts.poppins(fontSize: 12)),
              Switch(
                value: _pendingOnly,
                activeThumbColor: Colors.white,
                onChanged: (v) => setState(() => _pendingOnly = v),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          // ── Loading ────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ──────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          // ── Empty ──────────────────────────────────────────────────────
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _pendingOnly
                        ? 'No pending orders right now.'
                        : 'No orders found.\nAdd orders in Firestore to see them here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // ── Data ───────────────────────────────────────────────────────
          final docs = snapshot.data!.docs;

          return Column(
            children: [
              _buildSummaryBanner(docs),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildOrderCard(docs[index].data(), docs[index].id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery(String vendorId, bool pendingOnly) {
    var query = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId);

    if (pendingOnly) {
      query = query.where('status', isEqualTo: 'pending');
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Widget _buildSummaryBanner(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return Container(
      color: Colors.deepOrange.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.bar_chart, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Text(
            'Total orders shown: ${docs.length}',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: Colors.deepOrange.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data, String docId) {
    final token = data['tokenNumber'] as int? ?? 0;
    final status = (data['status'] as String? ?? 'pending').toLowerCase();
    final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final isPaid = data['isPaid'] as bool? ?? false;
    final items = data['items'] as List<dynamic>? ?? [];

    final statusColor = _statusColors[status] ?? Colors.grey;
    final statusIcon = _statusIcons[status] ?? Icons.help_outline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token #$token',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Doc: $docId',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPaid ? 'Paid' : 'Unpaid',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isPaid
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Items list ───────────────────────────────────────────────
            if (items.isNotEmpty) ...[
              const Divider(height: 16),
              ...items.map((item) {
                final itemMap = item as Map<String, dynamic>? ?? {};
                final itemName = itemMap['name'] as String? ?? 'Item';
                final qty = itemMap['quantity'] as int? ?? 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record,
                          size: 8, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '$itemName × $qty',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // ── Footer ───────────────────────────────────────────────────
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total: ₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

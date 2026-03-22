import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../providers/vendor_provider.dart';

/// Screen for viewing and managing vendor orders with filters
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  String _selectedFilter = 'all';

  final Map<String, String> _filters = {
    'all': 'All Orders',
    'pending': 'Pending',
    'cooking': 'Preparing',
    'ready': 'Ready',
    'completed': 'Completed',
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.entries.map((entry) {
                final isSelected = _selectedFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = entry.key);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.deepOrange,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery(vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = OrderModel.fromFirestore(docs[index]);
                    return _OrderCard(order: order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery(String vendorId) {
    var query = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId);

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }
}


class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  static const _statusColors = {
    OrderStatus.pending: Colors.orange,
    OrderStatus.cooking: Colors.blue,
    OrderStatus.ready: Colors.green,
    OrderStatus.completed: Colors.grey,
    OrderStatus.rejected: Colors.red,
  };

  static const _statusLabels = {
    OrderStatus.pending: 'Pending',
    OrderStatus.cooking: 'Preparing',
    OrderStatus.ready: 'Ready',
    OrderStatus.completed: 'Completed',
    OrderStatus.rejected: 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[order.status] ?? Colors.grey;
    final statusLabel = _statusLabels[order.status] ?? 'Unknown';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            '#${order.token.length > 4 ? order.token.substring(order.token.length - 4) : order.token}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        title: Text(
          order.customerName.isNotEmpty ? order.customerName : 'Customer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDateTime(order.createdAt),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${order.totalAmount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items.isNotEmpty) ...[
                  Text(
                    'Items:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6),
                          const SizedBox(width: 8),
                          Text(
                            '${item.name} × ${item.quantity}',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                ],

                // Status update buttons
                if (order.status != OrderStatus.completed && order.status != OrderStatus.rejected) ...[
                  Text(
                    'Update Status:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _getNextStatuses(order.status).map((status) {
                      return ElevatedButton(
                        onPressed: () => _updateStatus(context, order.id, status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _statusColors[status],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_statusLabels[status]!),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<OrderStatus> _getNextStatuses(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:
        return [OrderStatus.cooking, OrderStatus.rejected];
      case OrderStatus.cooking:
        return [OrderStatus.ready];
      case OrderStatus.ready:
        return [OrderStatus.completed];
      case OrderStatus.completed:
      case OrderStatus.rejected:
        return [];
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    OrderStatus newStatus,
  ) async {
    final provider = VendorProvider();
    await provider.updateOrderStatus(orderId, newStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to ${_statusLabels[newStatus]}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

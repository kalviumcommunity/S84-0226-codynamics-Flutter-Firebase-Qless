import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cooking:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order is placed and waiting for vendor confirmation.';
      case OrderStatus.cooking:
        return 'Your food is being prepared.';
      case OrderStatus.ready:
        return 'Your order is ready for pickup!';
      case OrderStatus.completed:
        return 'Order completed. Enjoy your meal!';
      case OrderStatus.rejected:
        return 'Unfortunately, your order was rejected by the vendor.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading order details'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final order = OrderModel.fromFirestore(snapshot.data!);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Status Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getStatusColor(order.status).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'STATUS: ${order.status.name.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusMessage(order.status),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    if (order.status == OrderStatus.cooking && order.estimatedWaitTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Estimated wait: ~${order.estimatedWaitTime} mins',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Token & Items
              Text(
                'Order Details',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shop:', style: GoogleFonts.poppins()),
                          Text(
                            order.shopName,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Token:', style: GoogleFonts.poppins()),
                          Text(
                            order.token,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.quantity}x ${item.name}', style: GoogleFonts.poppins()),
                            Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: GoogleFonts.poppins()),
                          ],
                        ),
                      )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

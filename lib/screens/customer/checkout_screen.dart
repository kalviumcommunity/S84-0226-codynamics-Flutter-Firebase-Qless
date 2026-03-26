import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/queue_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String vendorId;
  final String shopName;

  const CheckoutScreen({
    super.key,
    required this.vendorId,
    required this.shopName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  final QueueService _queueService = QueueService();

  Future<void> _processPaymentAndOrder(BuildContext context, CartProvider cart) async {
    debugPrint('💳 Processing order...');
    setState(() => _isProcessing = true);

    // Mock payment delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final items = cart.items.values.map((item) => {
        'productId': item.menuItem.id,
        'name': item.menuItem.name,
        'price': item.menuItem.price,
        'quantity': item.quantity,
      }).toList();

      debugPrint('📦 Items count: ${items.length}, Vendor: ${widget.vendorId}');

      final queueData = await _queueService.placeOrderAndJoinQueue(
        vendorId: widget.vendorId,
        shopName: widget.shopName,
        totalAmount: cart.totalAmount,
        items: items,
      );

      debugPrint('✅ Queue data received: ${queueData['token']}');

      if (!context.mounted) return;

      cart.clearCart();

      // Show success modal with token
      _showTokenDialog(context, queueData['token'] ?? 'N/A', queueData['estimatedWaitTime'] ?? 0);

    } catch (e) {
      debugPrint('❌ Order error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showTokenDialog(BuildContext context, String token, int estimatedWaitTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Order Confirmed!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Queue Token is:', style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange),
              ),
              child: Text(
                token,
                style: GoogleFonts.righteous(fontSize: 32, color: Colors.deepOrange, letterSpacing: 4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Est. Wait Time: ~${estimatedWaitTime} mins',
              style: GoogleFonts.poppins(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange.shade700
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Show this token to the vendor when collecting your order.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // close checkout
                Navigator.pop(context); // back to shop list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty && !_isProcessing) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Order Summary - ${widget.shopName}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...cart.items.values.map((cartItem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${cartItem.quantity}x ${cartItem.menuItem.name}',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      Text(
                        '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(thickness: 1.5, height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${cart.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Mock Payment Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.payment, size: 40, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Mock Payment Gateway',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                    Text(
                      'This uses a mock integration. Clicking Pay Now will simulate a successful payment instantly.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade800),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processPaymentAndOrder(context, cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const FoodLoadingIndicator(size: 30)
                      : Text(
                          'Pay ₹${cart.totalAmount.toStringAsFixed(2)} Now',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
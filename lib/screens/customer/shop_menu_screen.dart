import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class ShopMenuScreen extends StatelessWidget {
  final String vendorId;
  final String shopName;

  const ShopMenuScreen({
    super.key,
    required this.vendorId,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          shopName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('menu_items')
            .where('vendorId', isEqualTo: vendorId)
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FoodLoadingIndicator(size: 40);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading menu',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No items available right now',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = MenuItemModel.fromFirestore(docs[index]);
              return _MenuItemCard(item: item);
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0 || cart.currentVendorId != vendorId) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(vendorId: vendorId, shopName: shopName),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cart.itemCount} items | ₹${cart.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text('View Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button Logic
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                final cartItem = cart.items[item.id];
                final quantity = cartItem?.quantity ?? 0;

                return quantity > 0
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.deepOrange,
                            onPressed: () => cart.removeItem(item.id),
                          ),
                          Text(
                            '$quantity',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.deepOrange,
                            onPressed: () => _handleAddToCart(context, cart),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () => _handleAddToCart(context, cart),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade50,
                          foregroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('ADD'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, CartProvider cart) {
    if (!cart.canAddItem(item)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Clear Cart?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            'Your cart contains items from another vendor. Do you want to clear it and add this item?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                cart.clearCart();
                cart.addItem(item);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Clear & Add'),
            ),
          ],
        ),
      );
    } else {
      cart.addItem(item);
    }
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
    );
  }
}
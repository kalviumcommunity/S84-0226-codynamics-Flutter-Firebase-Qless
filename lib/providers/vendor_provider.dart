import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

/// State management for vendor operations using ChangeNotifier
class VendorProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get vendorId => _auth.currentUser?.uid ?? '';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ── Menu Item Operations ────────────────────────────────────────────────

  Future<void> addMenuItem({
    required String name,
    required String description,
    required double price,
    required String category,
    String imageUrl = '',
    bool isAvailable = true,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _db.collection('menu_items').add({
        'vendorId': vendorId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _setError('Failed to add item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMenuItem({
    required String itemId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updates = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (isAvailable != null) updates['isAvailable'] = isAvailable;

      await _db.collection('menu_items').doc(itemId).update(updates);
    } catch (e) {
      _setError('Failed to update item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleItemAvailability(String itemId, bool currentStatus) async {
    try {
      await _db.collection('menu_items').doc(itemId).update({
        'isAvailable': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _setError('Failed to toggle availability: $e');
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _db.collection('menu_items').doc(itemId).delete();
    } catch (e) {
      _setError('Failed to delete item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Order Operations ────────────────────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _setError('Failed to update order status: $e');
    }
  }

  // ── Profile Operations ──────────────────────────────────────────────────

  Future<void> updateVendorProfile({
    required String shopName,
    required String ownerName,
    String? description,
    String? phone,
    String? address,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updates = <String, dynamic>{
        'shopName': shopName,
        'ownerName': ownerName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (description != null) updates['description'] = description;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      await _db.collection('users').doc(vendorId).update(updates);
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Analytics ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVendorAnalytics() async {
    try {
      final ordersSnapshot = await _db
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      int totalOrders = ordersSnapshot.docs.length;
      double totalRevenue = 0;
      int todayOrders = 0;
      Map<String, int> itemCounts = {};

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null && createdAt.isAfter(todayStart)) {
          todayOrders++;
        }

        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final itemMap = item as Map<String, dynamic>;
          final name = itemMap['name'] as String? ?? 'Unknown';
          final qty = itemMap['quantity'] as int? ?? 1;
          itemCounts[name] = (itemCounts[name] ?? 0) + qty;
        }
      }

      String mostOrderedItem = 'N/A';
      int maxCount = 0;
      itemCounts.forEach((name, itemCount) {
        if (itemCount > maxCount) {
          maxCount = itemCount;
          mostOrderedItem = name;
        }
      });

      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'todayOrders': todayOrders,
        'mostOrderedItem': mostOrderedItem,
        'mostOrderedCount': maxCount,
      };
    } catch (e) {
      _setError('Failed to load analytics: $e');
      return {};
    }
  }
}

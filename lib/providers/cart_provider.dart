import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';
import 'dart:math';

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});
  
  double get totalPrice => menuItem.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _currentVendorId;

  Map<String, CartItem> get items => _items;
  String? get currentVendorId => _currentVendorId;
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  bool canAddItem(MenuItemModel item) {
    if (_currentVendorId == null || _currentVendorId == item.vendorId) {
      return true;
    }
    return false;
  }

  void addItem(MenuItemModel item) {
    if (_currentVendorId != null && _currentVendorId != item.vendorId) {
      throw Exception('Cart contains items from another vendor. Please clear cart first.');
    }
    
    _currentVendorId = item.vendorId;
    
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += 1;
    } else {
      _items[item.id] = CartItem(menuItem: item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    
    if (_items.isEmpty) {
      _currentVendorId = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentVendorId = null;
    notifyListeners();
  }

  String generateOrderToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        5, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
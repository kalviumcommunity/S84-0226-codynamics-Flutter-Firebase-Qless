import 'package:cloud_firestore/cloud_firestore.dart';

/// Allowed values for [OrderModel.status].
enum OrderStatus { 
  pending,    // Order placed, awaiting vendor acceptance
  cooking,    // Order accepted and being prepared
  ready,      // Order ready for pickup/delivery
  completed,  // Order completed
  rejected    // Order has been rejected by the vendor
}

/// Represents a line item inside the `orders/{id}/items` subcollection.
class OrderItemModel {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      id: data['id'] as String? ?? '',
      menuItemId: data['menuItemId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'menuItemId': menuItemId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}

/// Represents an order document in the `orders` collection.
class OrderModel {
  final String id;
  final String userId;
  final String vendorId;
  final String shopName;
  final String token;
  final int? weekNumber;
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final bool isPaid;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    this.userId = '',
    required this.vendorId,
    this.shopName = 'Unknown Shop',
    required this.token,
    this.weekNumber,
    this.customerName = '',
    this.status = OrderStatus.pending,
    required this.totalAmount,
    this.isPaid = false,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      vendorId: data['vendorId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? 'Unknown Shop',
      token: data['token']?.toString() ?? '',
      weekNumber: data['weekNumber'] as int?,
      customerName: data['customerName'] as String? ?? '',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: data['isPaid'] as bool? ?? false,
      items: itemsData.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>)).toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'vendorId': vendorId,
        'shopName': shopName,
        'token': token,
        'weekNumber': weekNumber,
        'customerName': customerName,
        'status': status.name,
        'totalAmount': totalAmount,
        'isPaid': isPaid,
        'items': items.map((e) => e.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

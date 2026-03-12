import 'package:cloud_firestore/cloud_firestore.dart';

/// Allowed values for [OrderModel.status].
enum OrderStatus { pending, cooking, ready, completed }

/// Represents a line item inside the `orders/{id}/items` subcollection.
class OrderItemModel {
  final String id;
  final String menuItemId;
  final String name;       // denormalised snapshot of item name at order time
  final double price;      // denormalised snapshot of price at order time
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderItemModel(
      id: doc.id,
      menuItemId: data['menuItemId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'menuItemId': menuItemId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}

/// Represents an order document in the `orders` collection.
/// Line items are stored in the `items` subcollection.
class OrderModel {
  final String id;
  final String vendorId;
  final int tokenNumber;
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.vendorId,
    required this.tokenNumber,
    this.customerName = '',
    this.status = OrderStatus.pending,
    required this.totalAmount,
    this.isPaid = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderModel(
      id: doc.id,
      vendorId: data['vendorId'] as String? ?? '',
      tokenNumber: data['tokenNumber'] as int? ?? 0,
      customerName: data['customerName'] as String? ?? '',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: data['isPaid'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'vendorId': vendorId,
        'tokenNumber': tokenNumber,
        'customerName': customerName,
        'status': status.name,
        'totalAmount': totalAmount,
        'isPaid': isPaid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

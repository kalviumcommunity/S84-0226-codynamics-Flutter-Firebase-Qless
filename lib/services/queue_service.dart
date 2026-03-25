import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Generates a real-time digital token and creates the order using a transaction.
  /// This ensures that token numbers are strictly sequential without race conditions.
  Future<Map<String, dynamic>> placeOrderAndJoinQueue({
    required String vendorId,
    required String shopName,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? 'guest';

    // 1. Determine today's date string (e.g., "2023-10-25")
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final queueDocId = "${vendorId}_$todayStr";

    final queueRef = _db.collection('queue_tokens').doc(queueDocId);
    final globalTokenRef = _db.collection('app_counters').doc('order_tokens');
    final orderRef = _db.collection('orders').doc(); // Auto-generate ID

    int newTokenNumber = 0;
    int newGlobalTokenNumber = 0;
    int estimatedWaitTime = 0;

    await _db.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(queueRef);
      final globalTokenSnapshot = await transaction.get(globalTokenRef);

      if (queueSnapshot.exists) {
        final currentToken = queueSnapshot.data()?['currentToken'] as int? ?? 0;
        final lastToken = queueSnapshot.data()?['lastToken'] as int? ?? 0;

        newTokenNumber = lastToken + 1;
        int queueLength = newTokenNumber - currentToken;
        
        // Simple logic: 5 mins per person ahead in queue (can be customized)
        estimatedWaitTime = queueLength > 0 ? queueLength * 5 : 5;

        transaction.update(queueRef, {
          'lastToken': newTokenNumber,
        });
      } else {
        // First order of the day for this vendor
        newTokenNumber = 1;
        estimatedWaitTime = 5;

        transaction.set(queueRef, {
          'vendorId': vendorId,
          'date': todayStr,
          'currentToken': 1,
          'lastToken': 1,
          'isActive': true,
        });
      }

      final globalLastToken = globalTokenSnapshot.data()?['lastToken'] as int? ?? 0;
      newGlobalTokenNumber = globalLastToken + 1;

      if (globalTokenSnapshot.exists) {
        transaction.update(globalTokenRef, {
          'lastToken': newGlobalTokenNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(globalTokenRef, {
          'lastToken': newGlobalTokenNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Generate a globally unique, user-friendly token string.
      final tokenString = "T${newGlobalTokenNumber.toString().padLeft(5, '0')}";

      final orderData = {
        'userId': userId,
        'vendorId': vendorId,
        'shopName': shopName,
        'token': tokenString,
        'globalTokenNumber': newGlobalTokenNumber,
        'tokenNumber': newTokenNumber,
        'status': 'pending',
        'totalAmount': totalAmount,
        'items': items.map((item) => {
          'id': item['productId'] ?? '',
          'menuItemId': item['productId'] ?? '',
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
        }).toList(),
        'estimatedWaitTime': estimatedWaitTime,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(orderRef, orderData);
    });

    return {
      'orderId': orderRef.id,
      'token': "T${newGlobalTokenNumber.toString().padLeft(5, '0')}",
      'estimatedWaitTime': estimatedWaitTime,
      'tokenNumber': newTokenNumber,
      'globalTokenNumber': newGlobalTokenNumber,
    };
  }

  /// Vendor moves the queue forward
  Future<void> advanceQueue(String vendorId, String orderId, int tokenNumber) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final queueDocId = "${vendorId}_$todayStr";

    final queueRef = _db.collection('queue_tokens').doc(queueDocId);
    final orderRef = _db.collection('orders').doc(orderId);

    await _db.runTransaction((transaction) async {
      transaction.update(orderRef, {
        'status': 'ready',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(queueRef, {
        'currentToken': tokenNumber,
      });
    });
  }

  /// Mark order as completed
  Future<void> completeOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

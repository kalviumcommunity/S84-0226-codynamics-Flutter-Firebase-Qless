import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralises all Firestore read operations for the Qless app.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // ── Collection references ────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _menuItems =>
      _db.collection('menu_items');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ── Real-time streams ────────────────────────────────────────────────────

  /// Stream of ALL menu items (updates whenever Firestore changes).
  Stream<QuerySnapshot<Map<String, dynamic>>> menuItemsStream() =>
      _menuItems.orderBy('name').snapshots();

  /// Stream of users registered as vendors.
  Stream<QuerySnapshot<Map<String, dynamic>>> vendorsStream() =>
      _users.where('role', isEqualTo: 'vendor').snapshots();

  /// Stream of live orders, newest first.
  Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream() =>
      _orders.orderBy('createdAt', descending: true).snapshots();

  /// Stream of PENDING orders only (filtered query).
  Stream<QuerySnapshot<Map<String, dynamic>>> pendingOrdersStream() =>
      _orders
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots();

  // ── One-time reads ───────────────────────────────────────────────────────

  /// Fetch all documents from a collection once.
  Future<QuerySnapshot<Map<String, dynamic>>> getAllMenuItems() =>
      _menuItems.get();

  /// Fetch a single user profile by UID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) =>
      _users.doc(uid).get();
}

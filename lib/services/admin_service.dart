import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service for super admin operations
class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Admin Verification ──────────────────────────────────────────────────

  /// Check if current user is super admin
  Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false;

      final role = doc.data()?['role'] as String?;
      return role == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Get current user's full profile
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ── Vendor Management ───────────────────────────────────────────────────

  /// Stream of all vendor requests (pending, approved, rejected, blocked)
  Stream<QuerySnapshot<Map<String, dynamic>>> vendorRequestsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .snapshots();
  }

  /// Stream of pending vendor requests only
  Stream<QuerySnapshot<Map<String, dynamic>>> pendingVendorRequestsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Get vendor statistics
  Future<Map<String, int>> getVendorStats() async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'vendor')
          .get();

      int pending = 0;
      int approved = 0;
      int rejected = 0;
      int blocked = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'pending';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
          case 'blocked':
            blocked++;
            break;
        }
      }

      return {
        'total': snapshot.docs.length,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'blocked': blocked,
      };
    } catch (e) {
      print('Error fetching vendor stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'blocked': 0,
      };
    }
  }

  // ── Vendor Approval Actions ─────────────────────────────────────────────

  /// Approve a vendor request
  Future<void> approveVendor(String vendorId, {String? notes}) async {
    await _updateVendorStatus(
      vendorId: vendorId,
      status: VendorStatus.approved,
      adminNotes: notes,
      rejectionReason: null,
    );

    // Log the action
    await _logAdminAction(
      action: 'approve_vendor',
      targetUserId: vendorId,
      details: notes,
    );
  }

  /// Reject a vendor request
  Future<void> rejectVendor(String vendorId, {required String reason}) async {
    await _updateVendorStatus(
      vendorId: vendorId,
      status: VendorStatus.rejected,
      rejectionReason: reason,
    );

    // Log the action
    await _logAdminAction(
      action: 'reject_vendor',
      targetUserId: vendorId,
      details: reason,
    );
  }

  /// Block an approved vendor
  Future<void> blockVendor(String vendorId, {required String reason}) async {
    await _updateVendorStatus(
      vendorId: vendorId,
      status: VendorStatus.blocked,
      adminNotes: reason,
      isActive: false,
    );

    // Log the action
    await _logAdminAction(
      action: 'block_vendor',
      targetUserId: vendorId,
      details: reason,
    );
  }

  /// Unblock a vendor
  Future<void> unblockVendor(String vendorId) async {
    await _updateVendorStatus(
      vendorId: vendorId,
      status: VendorStatus.approved,
      isActive: true,
    );

    // Log the action
    await _logAdminAction(
      action: 'unblock_vendor',
      targetUserId: vendorId,
    );
  }

  /// Update vendor status
  Future<void> _updateVendorStatus({
    required String vendorId,
    required VendorStatus status,
    String? adminNotes,
    String? rejectionReason,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (adminNotes != null) updates['adminNotes'] = adminNotes;
    if (rejectionReason != null) updates['rejectionReason'] = rejectionReason;
    if (isActive != null) updates['isActive'] = isActive;

    await _db.collection('users').doc(vendorId).update(updates);
  }

  // ── Product Management ──────────────────────────────────────────────────

  /// Stream of all products
  Stream<QuerySnapshot<Map<String, dynamic>>> allProductsStream() {
    return _db
        .collection('menu_items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete a product (for inappropriate content)
  Future<void> deleteProduct(String productId, {required String reason}) async {
    await _db.collection('menu_items').doc(productId).delete();

    // Log the action
    await _logAdminAction(
      action: 'delete_product',
      targetUserId: productId,
      details: reason,
    );
  }

  // ── Admin Logs ──────────────────────────────────────────────────────────

  /// Log admin actions for audit trail
  Future<void> _logAdminAction({
    required String action,
    String? targetUserId,
    String? details,
  }) async {
    final adminId = _auth.currentUser?.uid;
    if (adminId == null) return;

    try {
      await _db.collection('admin_logs').add({
        'adminId': adminId,
        'action': action,
        'targetUserId': targetUserId,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }

  /// Stream of admin logs
  Stream<QuerySnapshot<Map<String, dynamic>>> adminLogsStream({int limit = 50}) {
    return _db
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ── System Statistics ───────────────────────────────────────────────────

  /// Get overall system statistics
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final usersSnapshot = await _db.collection('users').get();
      final productsSnapshot = await _db.collection('menu_items').get();
      final ordersSnapshot = await _db.collection('orders').get();

      int totalUsers = 0;
      int totalVendors = 0;
      int totalAdmins = 0;

      for (var doc in usersSnapshot.docs) {
        final role = doc.data()['role'] as String? ?? 'user';
        if (role == 'admin') {
          totalAdmins++;
        } else if (role == 'vendor') {
          totalVendors++;
        } else {
          totalUsers++;
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalVendors': totalVendors,
        'totalAdmins': totalAdmins,
        'totalProducts': productsSnapshot.docs.length,
        'totalOrders': ordersSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching system stats: $e');
      return {};
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// User roles in the system
enum UserRole {
  admin,    // Super admin with full system access
  vendor,   // Food vendor/seller
  user      // Regular customer
}

/// Vendor approval status
enum VendorStatus {
  pending,   // Awaiting admin approval
  approved,  // Approved and can sell
  rejected,  // Application rejected
  blocked    // Blocked by admin
}

/// Represents a user profile stored in Firestore `users/{uid}`.
class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  
  // Common fields
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Vendor-specific fields
  final String? shopName;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? description;
  final String? imageUrl;
  final VendorStatus? vendorStatus;
  final bool isActive;
  
  // Admin notes
  final String? adminNotes;
  final String? rejectionReason;

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name = '',
    required this.createdAt,
    required this.updatedAt,
    this.shopName,
    this.ownerName,
    this.phone,
    this.address,
    this.description,
    this.imageUrl,
    this.vendorStatus,
    this.isActive = true,
    this.adminNotes,
    this.rejectionReason,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Parse role
    final roleStr = data['role'] as String? ?? 'user';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.user,
    );
    
    // Parse vendor status
    VendorStatus? vendorStatus;
    if (role == UserRole.vendor) {
      final statusStr = data['status'] as String? ?? 'pending';
      vendorStatus = VendorStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => VendorStatus.pending,
      );
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: role,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shopName: data['shopName'] as String?,
      ownerName: data['ownerName'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      vendorStatus: vendorStatus,
      isActive: data['isActive'] as bool? ?? true,
      adminNotes: data['adminNotes'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'role': role.name,
        'name': name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
        if (shopName != null) 'shopName': shopName,
        if (ownerName != null) 'ownerName': ownerName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (vendorStatus != null) 'status': vendorStatus!.name,
        'isActive': isActive,
        if (adminNotes != null) 'adminNotes': adminNotes,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };
  
  /// Check if vendor is approved and can sell
  bool get canSell => role == UserRole.vendor && 
                      vendorStatus == VendorStatus.approved && 
                      isActive;
  
  /// Check if user is super admin
  bool get isAdmin => role == UserRole.admin;
  
  /// Get display name based on role
  String get displayName {
    if (role == UserRole.vendor && shopName != null && shopName!.isNotEmpty) {
      return shopName!;
    }
    return name.isNotEmpty ? name : email;
  }
}

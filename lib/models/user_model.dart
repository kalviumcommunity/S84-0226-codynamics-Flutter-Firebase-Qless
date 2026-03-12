import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a vendor's profile stored in Firestore `users/{uid}`.
class UserModel {
  final String uid;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.shopName,
    required this.ownerName,
    required this.email,
    this.phone = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      shopName: data['shopName'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'shopName': shopName,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

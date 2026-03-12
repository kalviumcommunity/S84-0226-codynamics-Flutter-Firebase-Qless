import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks the daily token counter for a vendor in the `queue_tokens` collection.
/// Document ID format: `{vendorId}_{YYYY-MM-DD}` for O(1) lookup.
class QueueTokenModel {
  final String docId;       // "{vendorId}_{date}"
  final String vendorId;
  final String date;        // YYYY-MM-DD
  final int currentToken;
  final int lastToken;
  final bool isActive;

  const QueueTokenModel({
    required this.docId,
    required this.vendorId,
    required this.date,
    required this.currentToken,
    required this.lastToken,
    this.isActive = true,
  });

  factory QueueTokenModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return QueueTokenModel(
      docId: doc.id,
      vendorId: data['vendorId'] as String? ?? '',
      date: data['date'] as String? ?? '',
      currentToken: data['currentToken'] as int? ?? 0,
      lastToken: data['lastToken'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'vendorId': vendorId,
        'date': date,
        'currentToken': currentToken,
        'lastToken': lastToken,
        'isActive': isActive,
      };

  /// Builds the deterministic document ID from vendor UID and today's date.
  static String buildDocId(String vendorId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${vendorId}_$y-$m-$d';
  }
}

/// Represents a menu category in the `categories` collection.
class CategoryModel {
  final String id;
  final String vendorId;
  final String name;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.vendorId,
    required this.name,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      vendorId: data['vendorId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'vendorId': vendorId,
        'name': name,
        'sortOrder': sortOrder,
      };
}

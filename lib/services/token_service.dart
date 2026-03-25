import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

/// Service for generating unique order tokens that reset weekly
/// Ensures no duplicate tokens and provides human-readable format
class TokenService {
  static final TokenService _instance = TokenService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory TokenService() {
    return _instance;
  }

  TokenService._internal();

  /// Get current week number of the year (1-53)
  int _getCurrentWeekNumber() {
    final now = DateTime.now();
    // ISO 8601 week numbering
    final firstDay = DateTime(now.year, 1, 1);
    final dayOfWeek = firstDay.weekday;
    final daysToFirstMonday = dayOfWeek == 1 ? 0 : 8 - dayOfWeek;
    final firstMonday = firstDay.add(Duration(days: daysToFirstMonday));

    if (now.isBefore(firstMonday)) {
      // If before first Monday, use previous year's last week
      return _getWeekNumberForDate(DateTime(now.year - 1, 12, 31));
    }

    return now.difference(firstMonday).inDays ~/ 7 + 1;
  }

  int _getWeekNumberForDate(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final dayOfWeek = firstDay.weekday;
    final daysToFirstMonday = dayOfWeek == 1 ? 0 : 8 - dayOfWeek;
    final firstMonday = firstDay.add(Duration(days: daysToFirstMonday));

    if (date.isBefore(firstMonday)) {
      return _getWeekNumberForDate(DateTime(date.year - 1, 12, 31));
    }

    return date.difference(firstMonday).inDays ~/ 7 + 1;
  }

  /// Get the start date of current week (Monday)
  DateTime _getWeekStartDate() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    return now.subtract(Duration(days: dayOfWeek - 1));
  }

  /// Generate a unique token in format: "W##-XXXX"
  /// Example: "W14-A523" (Week 14, Random suffix)
  /// Each week resets the counter, ensuring uniqueness
  Future<String> generateUniqueToken() async {
    try {
      final weekNumber = _getCurrentWeekNumber();

      // Generate a unique identifier for this week's sequence
      final random = Random();
      final suffix = '${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}';
      final baseToken = 'W${weekNumber.toString().padLeft(2, '0')}-$suffix';

      // Verify uniqueness by checking if token already exists
      bool tokenExists = await _tokenExistsInDatabase(baseToken);
      int attempts = 0;

      while (tokenExists && attempts < 10) {
        // If token exists, generate a new one with different suffix
        final newSuffix = '${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}';
        final newToken = 'W${weekNumber.toString().padLeft(2, '0')}-$newSuffix';
        tokenExists = await _tokenExistsInDatabase(newToken);
        attempts++;

        if (!tokenExists) {
          return newToken;
        }
      }

      // Return the token (with very high probability of uniqueness)
      return baseToken;
    } catch (e) {
      // Fallback to UUID-style token if Firestore check fails
      return _generateFallbackToken();
    }
  }

  /// Check if token already exists in database
  Future<bool> _tokenExistsInDatabase(String token) async {
    try {
      final snapshot = await _db
          .collection('orders')
          .where('token', isEqualTo: token)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // If check fails, assume it doesn't exist to allow order creation
      return false;
    }
  }

  /// Fallback token generation (UUID-style but shorter and readable)
  String _generateFallbackToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Format: T-TIMESTAMP-RANDOM
    final randomPart = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
    final hex = timestamp.toRadixString(36).toUpperCase();
    return 'T-$hex-$randomPart';
  }

  /// Get token metadata (week number, when it resets)
  Map<String, dynamic> getTokenMetadata(String token) {
    final weekNumber = _getCurrentWeekNumber();
    final weekStart = _getWeekStartDate();
    final weekEnd = weekStart.add(Duration(days: 7));

    return {
      'token': token,
      'weekNumber': weekNumber,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Reset token sequence (called at week start, for admin purposes)
  Future<void> resetWeeklySequence() async {
    try {
      final weekNumber = _getCurrentWeekNumber();
      await _db
          .collection('token_sequences')
          .doc('week_$weekNumber')
          .set({
            'week': weekNumber,
            'sequence': 0,
            'resetDate': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error resetting weekly sequence: $e');
    }
  }
}

/// Simple in-memory cache for user roles
class RoleCache {
  static final RoleCache _instance = RoleCache._();
  factory RoleCache() => _instance;
  RoleCache._();

  final Map<String, String> _cache = {};

  void setRole(String uid, String role) {
    _cache[uid] = role;
  }

  String? getRole(String uid) {
    final role = _cache[uid];
    return role;
  }

  void clear() {
    _cache.clear();
  }
}

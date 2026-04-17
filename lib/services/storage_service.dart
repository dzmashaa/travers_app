import 'package:shared_preferences/shared_preferences.dart';
import 'package:travers_app/models/user_role.dart';

class StorageService {
  static const String _roleKey = 'user_role';

  static Future<void> saveRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
  }

  static Future<UserRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_roleKey);

    if (roleString == null) return null;

    return UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.participant,
    );
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
}

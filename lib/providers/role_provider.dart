import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/services/storage_service.dart';

final roleProvider = AsyncNotifierProvider<RoleNotifier, UserRole?>(() {
  return RoleNotifier();
});

class RoleNotifier extends AsyncNotifier<UserRole?> {
  @override
  Future<UserRole?> build() async {
    return await StorageService.getRole();
  }

  Future<void> setRole(UserRole role) async {
    await StorageService.saveRole(role);
    state = AsyncData(role);
  }

  Future<void> clearRole() async {
    await StorageService.clearRole();
    state = const AsyncData(null);
  }
}

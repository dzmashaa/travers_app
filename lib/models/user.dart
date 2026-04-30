import 'package:travers_app/models/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final UserRole role;

  UserModel({required this.id, required this.name, required this.role});
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.participant,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role.name};
  }
}

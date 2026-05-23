import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncRepositoryProvider = Provider((ref) => SyncRepository());

class SyncRepository {
  final _db = FirebaseFirestore.instance;
  Future<bool> hasPendingWrites() async {
    try {
      await _db.waitForPendingWrites().timeout(const Duration(seconds: 2));
      return false;
    } catch (e) {
      return true;
    }
  }
}

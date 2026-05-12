import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/penalty_rule.dart';

final penaltyRulesProvider = FutureProvider<List<PenaltyRule>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/penalties.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => PenaltyRule.fromJson(json)).toList();
});

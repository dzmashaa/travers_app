import 'package:travers_app/core/models/judging_target.dart';
import 'package:travers_app/core/models/result.dart';

class AggregatedResult {
  final JudgingTarget target;
  final int pureTimeMs;
  final int totalPenalties;
  final int finalCalculatedTimeMs;
  final List<ResultModel> blockResults;

  AggregatedResult({
    required this.target,
    required this.pureTimeMs,
    required this.totalPenalties,
    required this.finalCalculatedTimeMs,
    required this.blockResults,
  });

  AggregatedResult copyWith({
    int? pureTimeMs,
    int? totalPenalties,
    int? finalCalculatedTimeMs,
    List<ResultModel>? blockResults,
  }) {
    return AggregatedResult(
      target: target,
      pureTimeMs: pureTimeMs ?? this.pureTimeMs,
      totalPenalties: totalPenalties ?? this.totalPenalties,
      finalCalculatedTimeMs:
          finalCalculatedTimeMs ?? this.finalCalculatedTimeMs,
      blockResults: blockResults ?? this.blockResults,
    );
  }

  String get formattedFinalTime {
    final min = (finalCalculatedTimeMs ~/ 60000).toString().padLeft(2, '0');
    final sec = ((finalCalculatedTimeMs % 60000) ~/ 1000).toString().padLeft(
      2,
      '0',
    );
    final hd = ((finalCalculatedTimeMs % 1000) ~/ 10).toString().padLeft(
      2,
      '0',
    );
    return '$min:$sec.$hd';
  }

  String get formattedPureTime {
    final min = (pureTimeMs ~/ 60000).toString().padLeft(2, '0');
    final sec = ((pureTimeMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    final hd = ((pureTimeMs % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$min:$sec.$hd';
  }
}

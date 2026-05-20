import 'package:flutter/material.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/utils/time_extension.dart';

class StageResultCard extends StatelessWidget {
  final String blockName;
  final int index;
  final ResultModel result;

  const StageResultCard({
    super.key,
    required this.blockName,
    required this.index,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final penalties = result.appliedPenalties;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$index. $blockName',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.timeTotalMs.toFormattedTime(
                      includeHundredths: false,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.penaltiesSum} б.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: result.penaltiesSum > 0
                          ? const Color(0xFFD32F2F)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (penalties.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            ...penalties.map((penalty) => _buildPenaltyRow(penalty)),
          ],
        ],
      ),
    );
  }

  Widget _buildPenaltyRow(AppliedPenalty penalty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              penalty.reason,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
            ),
          ),
          Text(
            penalty.isDisqualification ? 'ЗНЯТТЯ' : '${penalty.points} б.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

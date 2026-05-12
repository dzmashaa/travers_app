class PenaltyRule {
  final String code;
  final String reason;
  final int points;
  final bool isDisqualification;
  final bool mustFix;

  PenaltyRule({
    required this.code,
    required this.reason,
    required this.points,
    this.isDisqualification = false,
    this.mustFix = false,
  });

  factory PenaltyRule.fromJson(Map<String, dynamic> json) {
    return PenaltyRule(
      code: json['code'] ?? '',
      reason: json['reason'] ?? '',
      points: json['points'] ?? 0,
      isDisqualification: json['isDisqualification'] ?? false,
      mustFix: json['mustFix'] ?? false,
    );
  }
}

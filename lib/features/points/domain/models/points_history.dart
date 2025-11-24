class PointsHistory {
  final String id;
  final String userId;
  final int amount;
  final String reason;
  final String? relatedContributionId;
  final DateTime? createdAt;

  const PointsHistory({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    this.relatedContributionId,
    this.createdAt,
  });

  factory PointsHistory.fromJson(Map<String, dynamic> json) {
    return PointsHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: json['amount'] as int,
      reason: json['reason'] as String,
      relatedContributionId: json['related_contribution_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'reason': reason,
      'related_contribution_id': relatedContributionId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

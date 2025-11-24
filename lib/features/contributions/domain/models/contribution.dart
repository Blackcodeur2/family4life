class Contribution {
  final String id;
  final String userId;
  final String? beneficiaryId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final DateTime? createdAt;

  const Contribution({
    required this.id,
    required this.userId,
    this.beneficiaryId,
    required this.amount,
    this.currency = 'XAF',
    this.status = 'completed',
    this.paymentMethod,
    this.createdAt,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      beneficiaryId: json['beneficiary_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XAF',
      status: json['status'] as String? ?? 'completed',
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'beneficiary_id': beneficiaryId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

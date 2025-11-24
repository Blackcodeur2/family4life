class Beneficiary {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String? photoUrl;
  final bool isEligible;
  final DateTime? createdAt;

  const Beneficiary({
    required this.id,
    required this.fullName,
    required this.birthDate,
    this.photoUrl,
    this.isEligible = true,
    this.createdAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      photoUrl: json['photo_url'] as String?,
      isEligible: json['is_eligible'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String(),
      'photo_url': photoUrl,
      'is_eligible': isEligible,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

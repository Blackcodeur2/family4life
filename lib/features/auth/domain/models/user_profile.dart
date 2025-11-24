class UserProfile {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? phoneNumber;
  final String? gender;
  final DateTime? birthDate;
  final String? avatarUrl;
  final int pointsBalance;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.gender,
    this.birthDate,
    this.avatarUrl,
    this.pointsBalance = 0,
    this.isAdmin = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      pointsBalance: json['points_balance'] as int? ?? 0,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'avatar_url': avatarUrl,
      'points_balance': pointsBalance,
      'is_admin': isAdmin,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

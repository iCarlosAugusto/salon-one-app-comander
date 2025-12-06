/// Employee model representing a staff member
class EmployeeModel {
  final String id;
  final String salonId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String role;
  final String? hiredAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.salonId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.role = 'barber',
    this.hiredAt,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full name of the employee
  String get fullName => '$firstName $lastName';

  /// Get initials for avatar fallback
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      salonId: json['salonId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'barber',
      hiredAt: json['hiredAt'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'role': role,
      'hiredAt': hiredAt,
      'isActive': isActive,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? salonId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    String? role,
    String? hiredAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      hiredAt: hiredAt ?? this.hiredAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Authenticated user model with multi-tenant support
class AuthUser {
  final String id;
  final String email;
  final UserRole role;
  final String salonId;
  final String? displayName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.salonId,
    this.displayName,
  });

  /// Create from Supabase user data combined with backend role data
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      salonId: json['salonId'] as String? ?? json['salon_id'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? json['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'salonId': salonId,
      'displayName': displayName,
    };
  }

  /// Check if user has admin privileges
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has employee privileges
  bool get isEmployee => role == UserRole.employee;

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, role: ${role.value}, salonId: $salonId)';
}

/// User roles for multi-tenant authorization
enum UserRole {
  admin('admin'),
  employee('employee');

  const UserRole(this.value);
  final String value;

  /// Create UserRole from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toLowerCase(),
      orElse: () => UserRole.employee,
    );
  }
}

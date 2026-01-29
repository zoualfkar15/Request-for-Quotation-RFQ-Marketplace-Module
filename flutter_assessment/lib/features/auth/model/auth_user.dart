class AuthUser {
  final int id;
  final String email;
  final String username;
  final String role;
  final String? companyName;
  final String? phone;

  AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.companyName,
    this.phone,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      email: (json['email'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      companyName: json['company_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}



class AppUser {
  final int id;
  final String username;
  final String email;
  final String role;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'] ?? 'user',
    );
  }
}

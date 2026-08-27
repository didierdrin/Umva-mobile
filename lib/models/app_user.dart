// lib/models/app_user.dart
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return email.isNotEmpty ? email[0].toUpperCase() : '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

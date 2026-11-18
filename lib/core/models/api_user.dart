class ApiUser {
  final int id;
  final String name;
  final String email;
  final String? nim;
  final String role;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        nim: json['nim'] as String?,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'nim': nim,
        'role': role,
      };

  bool get isAdmin => role == 'admin';
  bool get isMahasiswa => role == 'mahasiswa';
}
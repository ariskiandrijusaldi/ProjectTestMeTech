import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'auth_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userNimKey = 'user_nim';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> getToken() async => _storage.read(key: _key);

  Future<void> saveUser({
    required int id,
    required String name,
    required String email,
    required String? nim,
    required String role,
  }) async {
    await _storage.write(key: _userIdKey, value: id.toString());
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNimKey, value: nim ?? '');
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async => _storage.read(key: _roleKey);

  Future<Map<String, String>?> getUser() async {
    final id = await _storage.read(key: _userIdKey);
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    final nim = await _storage.read(key: _userNimKey);
    final role = await _storage.read(key: _roleKey);
    if (id == null || role == null) return null;
    return {
      'id': id,
      'name': name ?? '',
      'email': email ?? '',
      'nim': nim ?? '',
      'role': role,
    };
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
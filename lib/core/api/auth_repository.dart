import '../api/api_service.dart';
import '../models/api_user.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> login({
    required String emailOrNim,
    required String password,
    String? deviceName,
  }) async {
    final response = await _api.post('/login', body: {
      'email': emailOrNim,
      'password': password,
      ...? (deviceName != null ? {'device_name': deviceName} : null),
    });
    return ApiService.decode(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String nim,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    final response = await _api.post('/register', body: {
      'name': name,
      'email': email,
      'nim': nim,
      'password': password,
      'password_confirmation': passwordConfirmation,
      ...? (deviceName != null ? {'device_name': deviceName} : null),
    });
    return ApiService.decode(response);
  }

  Future<void> logout() async {
    final response = await _api.post('/logout');
    ApiService.decode(response);
  }

  Future<ApiUser> me() async {
    final response = await _api.get('/me');
    final data = ApiService.decode(response);
    final userData = data['data'] ?? data;
    return ApiUser.fromJson(userData);
  }

  /// Convenience: perform login + save token + save user profile.
  Future<ApiUser> loginAndSave({
    required String emailOrNim,
    required String password,
    String? deviceName,
  }) async {
    final response = await login(
      emailOrNim: emailOrNim,
      password: password,
      deviceName: deviceName,
    );
    return _saveSession(response, 'login');
  }

  /// Convenience: perform register + save token + save user profile.
  Future<ApiUser> registerAndSave({
    required String name,
    required String email,
    required String nim,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    final response = await register(
      name: name,
      email: email,
      nim: nim,
      password: password,
      passwordConfirmation: passwordConfirmation,
      deviceName: deviceName,
    );
    return _saveSession(response, 'registrasi');
  }

  Future<ApiUser> _saveSession(Map<String, dynamic> response, String action) async {
    final payload = response['data'] is Map
        ? Map<String, dynamic>.from(response['data'] as Map)
        : response;
    final token = payload['token'] as String?;
    final userData = payload['user'];
    if (token == null || userData is! Map) {
      throw ApiException(
        statusCode: 500,
        message: 'Respons $action tidak valid.',
      );
    }
    await _api.tokenStorage.saveToken(token);
    final user = ApiUser.fromJson(Map<String, dynamic>.from(userData));
    await _api.tokenStorage.saveUser(
      id: user.id,
      name: user.name,
      email: user.email,
      nim: user.nim,
      role: user.role,
    );
    return user;
  }
}
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../api/auth_repository.dart';
import '../models/api_user.dart';
import '../storage/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final TokenStorage _storage = TokenStorage();
  final AuthRepository _authRepo = AuthRepository();

  Map<String, String>? _user;
  bool _isLoading = true;
  bool _loggingOut = false;

  AuthProvider() {
    ApiService.onUnauthorized = () {
      logout();
    };
    _init();
  }

  Map<String, String>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get role => _user?['role'];
  bool get isAdmin => role == 'admin';
  bool get isMahasiswa => role == 'mahasiswa';

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        // Coba validasi token ke server lewat /api/me
        try {
          final apiUser = await _authRepo.me();
          await _saveApiUser(apiUser);
        } on ApiException catch (e) {
          if (e.statusCode == 401) {
            _user = null;
            await _storage.clear();
          } else {
            // Jika offline atau server bermasalah, gunakan data cache lokal
            _user = await _storage.getUser();
          }
        } catch (_) {
          _user = await _storage.getUser();
        }
      } else {
        _user = null;
      }
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveApiUser(ApiUser apiUser) async {
    _user = {
      'id': apiUser.id.toString(),
      'name': apiUser.name,
      'email': apiUser.email,
      'nim': apiUser.nim ?? '',
      'role': apiUser.role,
    };
    await _storage.saveUser(
      id: apiUser.id,
      name: apiUser.name,
      email: apiUser.email,
      nim: apiUser.nim,
      role: apiUser.role,
    );
  }

  Future<ApiUser> login(String emailOrNim, String password) async {
    final apiUser = await _authRepo.loginAndSave(
      emailOrNim: emailOrNim,
      password: password,
    );
    await _saveApiUser(apiUser);
    notifyListeners();
    return apiUser;
  }

  Future<ApiUser> register({
    required String name,
    required String nim,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final apiUser = await _authRepo.registerAndSave(
      name: name,
      nim: nim,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _saveApiUser(apiUser);
    notifyListeners();
    return apiUser;
  }

  Future<void> setUser(Map<String, String> user) async {
    _user = user;
    final nimVal = user['nim'];
    await _storage.saveUser(
      id: int.tryParse(user['id'] ?? '0') ?? 0,
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      nim: (nimVal == null || nimVal.isEmpty) ? null : nimVal,
      role: user['role'] ?? '',
    );
    notifyListeners();
  }

  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;

    try {
      await _authRepo.logout();
    } catch (_) {
      // Token mungkin sudah tidak valid; tetap bersihkan sesi lokal.
    } finally {
      _user = null;
      await _storage.clear();
      _loggingOut = false;
      notifyListeners();
    }
  }
}

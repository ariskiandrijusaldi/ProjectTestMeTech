import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode: $message)';
}

class ApiService {
  /// Default base URL berdasarkan platform (10.0.2.2 untuk Android emulator, 127.0.0.1 untuk lainnya).
  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.1.9:8000/api';
    }
    return 'http://192.168.1.9:8000/api';
  }

  static String baseUrl = defaultBaseUrl;

  /// Callback global saat server merespons 401 Unauthorized.
  static VoidCallback? onUnauthorized;

  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiService({http.Client? client, TokenStorage? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  TokenStorage get tokenStorage => _tokenStorage;

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStorage.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = await _headers();
    final response = await _client.get(uri, headers: headers);
    await _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> post(String path, {dynamic body}) async {
    final headers = await _headers();
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body is Map<String, dynamic> ? jsonEncode(body) : body,
    );
    await _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> patch(String path, {dynamic body}) async {
    final headers = await _headers();
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body is Map<String, dynamic> ? jsonEncode(body) : body,
    );
    await _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> put(String path, {dynamic body}) async {
    final headers = await _headers();
    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body is Map<String, dynamic> ? jsonEncode(body) : body,
    );
    await _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    final response = await _client.delete(Uri.parse('$baseUrl$path'), headers: headers);
    await _checkUnauthorized(response);
    return response;
  }

  /// Upload multipart (misal buku dengan file cover)
  Future<http.Response> multipart({
    required String method,
    required String path,
    required Map<String, String> fields,
    http.MultipartFile? file,
  }) async {
    final token = await _tokenStorage.getToken();
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest(method, uri);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(file);
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    await _checkUnauthorized(response);
    return response;
  }

  Future<void> _checkUnauthorized(http.Response response) async {
    if (response.statusCode != 401) return;

    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    await _tokenStorage.clear();
    onUnauthorized?.call();
  }

  /// Decode response body. Throw [ApiException] on 4xx/5xx.
  static Map<String, dynamic> decode(http.Response response) {
    if (response.statusCode >= 400) {
      final errors = <String, dynamic>{};
      String message = 'Terjadi kesalahan (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          message = body['message'] ?? message;
          if (body['errors'] is Map) {
            errors.addAll(Map<String, dynamic>.from(body['errors']));
          }
        }
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : message;
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
        errors: errors.isNotEmpty ? errors : null,
      );
    }
    if (response.body.isEmpty) return {};
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Format respons tidak valid.',
      );
    }
    return body;
  }
}

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';

class AdminRepository {
  final ApiService _api;

  AdminRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Map<String, dynamic>>> listUsers() async {
    final response = await _api.get('/admin/users');
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  Future<List<Map<String, dynamic>>> listCategories() async {
    final response = await _api.get('/admin/categories');
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  // ---------- BOOKS ----------
  Future<Map<String, dynamic>> listBooks({
    String? search,
    int? categoryId,
    int page = 1,
    int perPage = 100,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId.toString();
    final response = await _api.get('/admin/books', query: query);
    return ApiService.decode(response);
  }

  Future<Map<String, dynamic>> createBook({
    required int categoryId,
    required String isbn,
    required String title,
    required String author,
    String? publisher,
    int? year,
    String? synopsis,
    String? rackLocation,
    required int stockTotal,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final response = await _api.multipart(
      method: 'POST',
      path: '/admin/books',
      fields: _bookFields(
        categoryId: categoryId,
        isbn: isbn,
        title: title,
        author: author,
        publisher: publisher,
        year: year,
        synopsis: synopsis,
        rackLocation: rackLocation,
        stockTotal: stockTotal,
      ),
      file: _coverFile(coverBytes, coverFileName),
    );
    return ApiService.decode(response);
  }

  Future<Map<String, dynamic>> updateBook({
    required int bookId,
    required int categoryId,
    required String isbn,
    required String title,
    required String author,
    String? publisher,
    int? year,
    String? synopsis,
    String? rackLocation,
    required int stockTotal,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final response = await _api.multipart(
      method: 'POST',
      path: '/admin/books/$bookId',
      fields: {
        '_method': 'PUT',
        ..._bookFields(
          categoryId: categoryId,
          isbn: isbn,
          title: title,
          author: author,
          publisher: publisher,
          year: year,
          synopsis: synopsis,
          rackLocation: rackLocation,
          stockTotal: stockTotal,
        ),
      },
      file: _coverFile(coverBytes, coverFileName),
    );
    return ApiService.decode(response);
  }

  Map<String, String> _bookFields({
    required int categoryId,
    required String isbn,
    required String title,
    required String author,
    String? publisher,
    int? year,
    String? synopsis,
    String? rackLocation,
    required int stockTotal,
  }) {
    return {
      'category_id': categoryId.toString(),
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': ?publisher,
      if (year != null) 'year': year.toString(),
      'synopsis': ?synopsis,
      'rack_location': ?rackLocation,
      'stock_total': stockTotal.toString(),
    };
  }

  http.MultipartFile? _coverFile(Uint8List? bytes, String? fileName) {
    if (bytes == null || fileName == null) return null;
    return http.MultipartFile.fromBytes('cover', bytes, filename: fileName);
  }

  Future<void> deleteBook(int bookId) async {
    final response = await _api.delete('/admin/books/$bookId');
    ApiService.decode(response);
  }

  // ---------- CATEGORIES ----------
  Future<Map<String, dynamic>> createCategory(String name) async {
    final response = await _api.post('/admin/categories', body: {'name': name});
    return ApiService.decode(response);
  }

  Future<Map<String, dynamic>> updateCategory(int categoryId, String name) async {
    final response = await _api.put(
      '/admin/categories/$categoryId',
      body: {'name': name},
    );
    return ApiService.decode(response);
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await _api.delete('/admin/categories/$categoryId');
    ApiService.decode(response);
  }
}
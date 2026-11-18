import '../api/api_service.dart';
import '../models/api_book.dart';

class BookRepository {
  final ApiService _api;

  BookRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ApiBook>> listBooks({
    String? search,
    int? categoryId,
    int page = 1,
    int perPage = 100,
  }) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId.toString();
    query['page'] = page.toString();
    query['per_page'] = perPage.toString();

    final response = await _api.get('/books', query: query);
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return list.map((e) => ApiBook.fromJson(e)).toList();
  }

  Future<ApiBook> getBook(int id) async {
    final response = await _api.get('/books/$id');
    final data = ApiService.decode(response);
    final bookData = data['data'] ?? data;
    return ApiBook.fromJson(bookData);
  }

  Future<List<ApiBook>> popularBooks() async {
    final response = await _api.get('/books/popular');
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return list.map((e) => ApiBook.fromJson(e)).toList();
  }
}
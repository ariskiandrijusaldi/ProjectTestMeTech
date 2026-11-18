import '../api/api_service.dart';

class CategoryRepository {
  final ApiService _api;

  CategoryRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Map<String, dynamic>>> listCategories() async {
    final response = await _api.get('/categories');
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return List<Map<String, dynamic>>.from(list);
  }
}
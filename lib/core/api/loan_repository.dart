import '../api/api_service.dart';
import '../models/api_loan.dart';

class LoanRepository {
  final ApiService _api;

  LoanRepository({ApiService? api}) : _api = api ?? ApiService();

  /// Student: request a loan
  Future<ApiLoan> requestLoan(int bookId) async {
    final response = await _api.post('/loans', body: {'book_id': bookId});
    final data = ApiService.decode(response);
    return ApiLoan.fromJson(data['data']);
  }

  /// Student: my loans
  Future<List<ApiLoan>> myLoans({String? tab, int page = 1, int perPage = 100}) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (tab != null && tab.isNotEmpty) query['tab'] = tab;

    final response = await _api.get('/my-loans', query: query);
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return list.map((e) => ApiLoan.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Student: cancel own pending loan
  Future<void> cancelLoan(int loanId) async {
    final response = await _api.delete('/my-loans/$loanId');
    ApiService.decode(response);
  }

  /// Admin: list loans
  Future<Map<String, dynamic>> adminLoans({
    String? status,
    String? search,
    int page = 1,
    int perPage = 100,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _api.get('/admin/loans', query: query);
    final data = ApiService.decode(response);
    final list = (data['data'] as List? ?? [])
        .map((e) => ApiLoan.fromJson(e))
        .toList();
    return {'data': list, 'meta': data['meta'] ?? {}, 'meta_counts': data['meta_counts'] ?? {}};
  }

  /// Admin: approve
  Future<ApiLoan> approveLoan(int loanId) async {
    final response = await _api.patch('/admin/loans/$loanId/approve');
    final data = ApiService.decode(response);
    return ApiLoan.fromJson(data['data']);
  }

  /// Admin: reject
  Future<ApiLoan> rejectLoan(int loanId, String reason) async {
    final response = await _api.patch(
      '/admin/loans/$loanId/reject',
      body: {'reason': reason},
    );
    final data = ApiService.decode(response);
    return ApiLoan.fromJson(data['data']);
  }

  /// Admin: return
  Future<ApiLoan> returnLoan(int loanId) async {
    final response = await _api.patch('/admin/loans/$loanId/return');
    final data = ApiService.decode(response);
    return ApiLoan.fromJson(data['data']);
  }

  /// Admin: pay fine
  Future<ApiLoan> payFine(int loanId) async {
    final response = await _api.patch('/admin/loans/$loanId/pay-fine');
    final data = ApiService.decode(response);
    return ApiLoan.fromJson(data['data']);
  }

  /// Admin: overdue loans
  Future<List<ApiLoan>> overdueLoans({int page = 1, int perPage = 100}) async {
    final response = await _api.get(
      '/admin/loans/overdue',
      query: {'page': page.toString(), 'per_page': perPage.toString()},
    );
    final data = ApiService.decode(response);
    final list = data['data'] as List? ?? [];
    return list.map((e) => ApiLoan.fromJson(e)).toList();
  }

  /// Admin: get loan by id
  Future<ApiLoan> adminLoanById(int id) async {
    final response = await _api.get('/admin/loans/$id');
    final data = ApiService.decode(response);
    return ApiLoan.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  /// Admin: loan by code
  Future<ApiLoan> loanByCode(String code) async {
    final response = await _api.get('/admin/loans/code/$code');
    final data = ApiService.decode(response);
    return ApiLoan.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }
}
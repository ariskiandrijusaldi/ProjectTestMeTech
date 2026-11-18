import 'api_book.dart';
import 'api_user.dart';

class ApiLoan {
  final int id;
  final String code;
  final String status;
  final String statusLabel;
  final DateTime? requestedAt;
  final DateTime? approvedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;
  final bool isOverdue;
  final int lateDays;
  final double fineAmount;
  final bool finePaid;
  final String? rejectedReason;
  final ApiUser? user;
  final ApiBook? book;
  final ApiUser? approvedBy;

  ApiLoan({
    required this.id,
    required this.code,
    required this.status,
    required this.statusLabel,
    this.requestedAt,
    this.approvedAt,
    this.dueDate,
    this.returnedAt,
    required this.isOverdue,
    required this.lateDays,
    required this.fineAmount,
    required this.finePaid,
    this.rejectedReason,
    this.user,
    this.book,
    this.approvedBy,
  });

  factory ApiLoan.fromJson(Map<String, dynamic> json) => ApiLoan(
        id: json['id'] as int,
        code: (json['code'] ?? json['loan_code'] ?? '-') as String,
        status: json['status'] as String,
        statusLabel: json['status_label'] as String? ?? json['status'] as String,
        requestedAt: json['requested_at'] != null
            ? DateTime.parse(json['requested_at'] as String)
            : null,
        approvedAt: json['approved_at'] != null
            ? DateTime.parse(json['approved_at'] as String)
            : null,
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        returnedAt: json['returned_at'] != null
            ? DateTime.parse(json['returned_at'] as String)
            : null,
        isOverdue: json['is_overdue'] as bool? ?? false,
        lateDays: (json['late_days'] as num? ?? 0).toInt(),
        fineAmount: (json['fine_amount'] as num? ?? 0).toDouble(),
        finePaid: json['fine_paid'] as bool? ?? false,
        rejectedReason: json['rejected_reason'] as String?,
        user: json['user'] != null ? ApiUser.fromJson(json['user']) : null,
        book: json['book'] != null ? ApiBook.fromJson(json['book']) : null,
        approvedBy: json['approved_by'] != null
            ? ApiUser.fromJson(json['approved_by'])
            : null,
      );
}
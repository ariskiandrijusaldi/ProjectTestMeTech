enum LoanStatus { pending, approved, rejected, returned }

class Loan {
  final String code; // contoh: #PJ250701
  final String bookTitle;
  final LoanStatus status;
  final String submittedAt; // contoh: "1 Jul 2025, 10:00"
  final String? processedAt; // null jika belum diproses admin
  final String dateLabel; // contoh: "Diajukan pada 1 Jul 2025"

  const Loan({
    required this.code,
    required this.bookTitle,
    required this.status,
    required this.submittedAt,
    required this.dateLabel,
    this.processedAt,
  });

  bool get isActive =>
      status == LoanStatus.pending || status == LoanStatus.approved;
}

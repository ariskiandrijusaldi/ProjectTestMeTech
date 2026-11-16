import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final LoanStatus status;
  const StatusChip(this.status, {super.key});

  static String labelOf(LoanStatus s) => switch (s) {
        LoanStatus.pending => 'Menunggu Persetujuan',
        LoanStatus.approved => 'Disetujui',
        LoanStatus.rejected => 'Ditolak',
        LoanStatus.returned => 'Dikembalikan',
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      LoanStatus.pending => (AppColors.pendingBg, AppColors.pendingFg),
      LoanStatus.approved => (AppColors.approvedBg, AppColors.approvedFg),
      LoanStatus.rejected => (AppColors.rejectedBg, AppColors.rejectedFg),
      LoanStatus.returned => (AppColors.approvedBg, AppColors.approvedFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(labelOf(status),
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

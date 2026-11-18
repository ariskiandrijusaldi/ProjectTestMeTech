import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final LoanStatus status;
  final bool compact;

  const StatusChip(this.status, {super.key, this.compact = false});
  const StatusChip.named({super.key, required this.status, this.compact = false});

  static String labelOf(LoanStatus s) => switch (s) {
        LoanStatus.pending => 'Menunggu',
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        labelOf(status),
        style: TextStyle(
          color: fg,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

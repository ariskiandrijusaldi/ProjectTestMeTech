import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/dummy_data.dart';
import '../../models/loan.dart';

class LoanHistoryPage extends StatelessWidget {
  const LoanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Status Peminjaman'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Aktif'), Tab(text: 'Riwayat')],
          ),
        ),
        body: TabBarView(
          children: [
            _LoanList(loans: dummyLoans.where((l) => l.isActive).toList()),
            _LoanList(loans: dummyLoans.where((l) => !l.isActive).toList()),
          ],
        ),
      ),
    );
  }
}

class _LoanList extends StatelessWidget {
  final List<Loan> loans;
  const _LoanList({required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return const Center(child: Text('Belum ada peminjaman'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: loans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _LoanCard(loan: loans[i]),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.bookTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(loan.code,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Text(loan.dateLabel,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    StatusChip(loan.status),
                  ],
                ),
              ),
            ],
          ),
          // Timeline hanya untuk pengajuan yang masih menunggu
          if (loan.status == LoanStatus.pending) ...[
            const SizedBox(height: 14),
            _Timeline(loan: loan),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final Loan loan;
  const _Timeline({required this.loan});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Pengajuan', loan.submittedAt, true),
      ('Diproses Admin', loan.processedAt ?? '-', loan.processedAt != null),
      ('Status Terakhir', StatusChip.labelOf(loan.status),
          loan.status != LoanStatus.pending),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      steps[i].$3
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: steps[i].$3
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                            width: 2, color: AppColors.primarySoft),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].$1,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(steps[i].$2,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

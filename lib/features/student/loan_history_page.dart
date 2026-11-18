import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/api/api_service.dart';
import '../../core/api/loan_repository.dart';
import '../../core/models/api_loan.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/loan.dart';

class LoanHistoryPage extends StatefulWidget {
  const LoanHistoryPage({super.key});

  @override
  State<LoanHistoryPage> createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage> {
  final LoanRepository _loanRepo = LoanRepository();
  List<ApiLoan> _active = [];
  List<ApiLoan> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final active = await _loanRepo.myLoans(tab: 'active');
      final history = await _loanRepo.myLoans(tab: 'history');
      if (!mounted) return;
      setState(() {
        _active = active;
        _history = history;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Gagal memuat riwayat peminjaman.';
        _loading = false;
      });
    }
  }

  Future<void> _cancelLoan(ApiLoan loan) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Batalkan Pengajuan',
      message: 'Apakah Anda yakin ingin membatalkan pengajuan pinjaman "${loan.book?.title ?? loan.code}"?',
      icon: Icons.cancel_outlined,
      confirmLabel: 'Ya, Batalkan',
      cancelLabel: 'Tidak',
      destructive: true,
    );

    if (confirmed != true) return;

    try {
      await _loanRepo.cancelLoan(loan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan peminjaman berhasil dibatalkan.'),
          backgroundColor: AppColors.approvedFg,
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: AppColors.rejectedFg,
        ),
      );
    }
  }

  void _showDetailModal(ApiLoan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loan.book?.title ?? 'Peminjaman Buku',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kode: ${loan.code}',
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surface),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: QrImageView(
                data: loan.code,
                version: QrVersions.auto,
                size: 160.0,
              ),
            ),
            const SizedBox(height: 16),
            StatusChip.named(status: _parseStatus(loan.status)),
            const SizedBox(height: 16),
            const Divider(),
            _detailRow('Status', loan.statusLabel),
            if (loan.requestedAt != null)
              _detailRow('Tgl Pengajuan', _formatDate(loan.requestedAt!)),
            if (loan.dueDate != null)
              _detailRow('Jatuh Tempo', _formatDate(loan.dueDate!)),
            if (loan.returnedAt != null)
              _detailRow('Dikembalikan', _formatDate(loan.returnedAt!)),
            if (loan.isOverdue)
              _detailRow('Keterlambatan', '${loan.lateDays} Hari', isRed: true),
            if (loan.fineAmount > 0)
              _detailRow(
                'Denda',
                '${_formatRupiah(loan.fineAmount)} (${loan.finePaid ? "Lunas" : "Belum Dibayar"})',
                isRed: !loan.finePaid,
              ),
            if (loan.rejectedReason != null && loan.rejectedReason!.isNotEmpty)
              _detailRow('Alasan Penolakan', loan.rejectedReason!, isRed: true),
            const SizedBox(height: 20),
            if (loan.status == 'pending') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rejectedFg,
                    side: const BorderSide(color: AppColors.rejectedFg),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cancelLoan(loan);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Batalkan Pengajuan'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isRed ? AppColors.rejectedFg : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Peminjaman Saya'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Aktif'), Tab(text: 'Riwayat')],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _LoanList(
                      loans: _active,
                      title: 'Aktif',
                      onTap: _showDetailModal,
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _LoanList(
                      loans: _history,
                      title: 'Riwayat',
                      onTap: _showDetailModal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  static String _formatRupiah(double n) {
    final s = n.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp$b';
  }

  static LoanStatus _parseStatus(String s) {
    switch (s) {
      case 'pending': return LoanStatus.pending;
      case 'approved': return LoanStatus.approved;
      case 'rejected': return LoanStatus.rejected;
      case 'returned': return LoanStatus.returned;
      default: return LoanStatus.pending;
    }
  }
}

class _LoanList extends StatelessWidget {
  final List<ApiLoan> loans;
  final String title;
  final ValueChanged<ApiLoan> onTap;

  const _LoanList({
    required this.loans,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text('Belum ada peminjaman $title.',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: loans.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _LoanCard(loan: loans[i], onTap: () => onTap(loans[i])),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final ApiLoan loan;
  final VoidCallback onTap;

  const _LoanCard({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                      Text(loan.book?.title ?? 'Buku Perpustakaan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(loan.code,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      if (loan.dueDate != null)
                        Text('Jatuh tempo: ${_LoanHistoryPageState._formatDate(loan.dueDate!)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      StatusChip.named(
                        status: _LoanHistoryPageState._parseStatus(loan.status),
                      ),
                      if (loan.isOverdue) ...[
                        const SizedBox(height: 4),
                        Text('Terlambat ${loan.lateDays} hari',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.rejectedFg)),
                      ],
                      if (loan.fineAmount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Denda ${_LoanHistoryPageState._formatRupiah(loan.fineAmount)} · ${loan.finePaid ? 'Lunas' : 'Belum lunas'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: loan.finePaid
                                ? AppColors.approvedFg
                                : AppColors.rejectedFg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            if (loan.status == 'pending') ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.hourglass_top, size: 14, color: AppColors.pendingFg),
                  SizedBox(width: 6),
                  Text('Menunggu persetujuan admin perpustakaan',
                      style: TextStyle(fontSize: 12, color: AppColors.pendingFg)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

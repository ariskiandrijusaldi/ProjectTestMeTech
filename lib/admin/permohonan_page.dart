import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'models.dart';
import 'pengembalian_page.dart';
import '../../core/api/loan_repository.dart';
import '../../core/models/api_loan.dart';
import '../../core/widgets/app_confirm_dialog.dart';

class PermohonanPage extends StatefulWidget {
  final VoidCallback? onBack;
  const PermohonanPage({super.key, this.onBack});

  @override
  State<PermohonanPage> createState() => _PermohonanPageState();
}

class _PermohonanPageState extends State<PermohonanPage> {
  final LoanRepository _loanRepo = LoanRepository();
  List<ApiLoan> _menunggu = [];
  List<ApiLoan> _riwayat = [];
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
      final pending = await _loanRepo.adminLoans(status: 'pending');
      final history = await _loanRepo.adminLoans(status: 'history');
      if (!mounted) return;
      setState(() {
        _menunggu = (pending['data'] as List<ApiLoan>? ?? []);
        _riwayat = (history['data'] as List<ApiLoan>? ?? []);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiError(e);
        _loading = false;
      });
    }
  }

  Future<void> _approve(ApiLoan p) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Setujui Permohonan',
      message: 'Setujui peminjaman #${p.code} (${p.book?.title ?? "Buku"})? Stok buku akan berkurang 1 dan batas waktu jatuh tempo adalah 7 hari.',
      icon: Icons.check_circle_outline_rounded,
      confirmLabel: 'Setujui',
    );

    if (confirmed != true) return;

    try {
      await _loanRepo.approveLoan(p.id);
      if (!mounted) return;
      showSnack(context, 'Permohonan #${p.code} disetujui');
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal menyetujui: ${apiError(e)}', error: true);
    }
  }

  Future<void> _reject(ApiLoan p) async {
    final alasan = await showDialog<String>(
      context: context,
      builder: (_) => const _TolakDialog(),
    );
    if (alasan == null || alasan.isEmpty || !mounted) return;

    try {
      await _loanRepo.rejectLoan(p.id, alasan);
      if (!mounted) return;
      showSnack(context, 'Permohonan #${p.code} ditolak');
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal menolak: ${apiError(e)}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                ),
                title: const Text('Permohonan Peminjaman'),
                bottom: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.border,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: [
                    Tab(text: 'Menunggu (${_menunggu.length})'),
                    const Tab(text: 'Riwayat'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _buildMenunggu(_menunggu),
                  ),
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _buildRiwayat(_riwayat),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _openLoan(ApiLoan loan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PengembalianPage(loanId: loan.id)),
    );
    if (mounted) _load();
  }

  Widget _buildMenunggu(List<ApiLoan> list) {
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: 'Tidak ada permohonan yang menunggu.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final p = list[i];
        return AdminCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemThumb(cover: p.book?.coverUrl ?? '', size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${p.code}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(p.book?.title ?? 'Buku tidak ditemukan',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(
                          '${p.user?.name ?? '-'}${p.user?.nim == null ? '' : ' · ${p.user!.nim}'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                        Text('Diajukan ${_formatTanggal(p.requestedAt)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size(84, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _reject(p),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(84, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _approve(p),
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayat(List<ApiLoan> list) {
    if (list.isEmpty) {
      return const EmptyState(icon: Icons.history, message: 'Riwayat masih kosong.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = list[i];
        final bisaDibuka = p.status == 'approved' || p.status == 'returned';
        return AdminCard(
          onTap: bisaDibuka ? () => _openLoan(p) : null,
          child: Row(
            children: [
              ItemThumb(cover: p.book?.coverUrl ?? '', size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${p.code}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                    Text('${p.book?.title ?? '-'} · ${p.user?.name ?? '-'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Row(children: [
                      StatusChip(status: _parseStatus(p.status)),
                      const SizedBox(width: 8),
                      Text(_formatTanggal(p.requestedAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ]),
                    if (p.status == 'rejected' && (p.rejectedReason ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Alasan: ${p.rejectedReason}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                      ),
                    if (p.isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Terlambat ${p.lateDays} hari',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger)),
                      ),
                    if (p.status == 'returned' && p.fineAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Denda ${_formatRupiah(p.fineAmount)} · ${p.finePaid ? 'Lunas' : 'Belum lunas'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.finePaid ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (bisaDibuka)
                const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        );
      },
    );
  }

  String _formatTanggal(DateTime? d) {
    if (d == null) return '-';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  String _formatRupiah(double n) {
    final s = n.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp$b';
  }

  LoanStatus _parseStatus(String s) {
    switch (s) {
      case 'pending': return LoanStatus.pending;
      case 'approved': return LoanStatus.approved;
      case 'rejected': return LoanStatus.rejected;
      case 'returned': return LoanStatus.returned;
      default: return LoanStatus.pending;
    }
  }
}

class _TolakDialog extends StatefulWidget {
  const _TolakDialog();

  @override
  State<_TolakDialog> createState() => _TolakDialogState();
}

class _TolakDialogState extends State<_TolakDialog> {
  final _formKey = GlobalKey<FormState>();
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 30),
            ),
            const SizedBox(height: 18),
            const Text('Tolak Permohonan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            const Text(
              'Berikan alasan penolakan agar mahasiswa mengetahui penyebabnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, height: 1.45, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _alasan,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan penolakan',
                  hintText: 'Contoh: Buku sedang dalam perbaikan fisik',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, _alasan.text.trim());
                  }
                },
                child: const Text('Tolak Permohonan',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: AppColors.muted,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

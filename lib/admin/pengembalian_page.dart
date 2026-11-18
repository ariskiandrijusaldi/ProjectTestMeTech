import 'package:flutter/material.dart';
import 'admin_common.dart';
import '../../core/api/loan_repository.dart';
import '../../core/models/api_loan.dart';
import '../../core/widgets/app_confirm_dialog.dart';

class PengembalianPage extends StatefulWidget {
  final int? loanId;
  final VoidCallback? onBack;
  const PengembalianPage({super.key, this.loanId, this.onBack});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final LoanRepository _loanRepo = LoanRepository();
  final TextEditingController _codeController = TextEditingController();

  ApiLoan? _loan;
  bool _loading = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    if (widget.loanId != null) {
      _loadById(widget.loanId!);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadById(int id) async {
    setState(() {
      _loading = true;
      _searchError = null;
    });
    try {
      final loan = await _loanRepo.adminLoanById(id);
      if (!mounted) return;
      setState(() {
        _loan = loan;
        _codeController.text = loan.code;
        _loading = false;
      });
    } catch (_) {
      // Fallback search in loans list
      try {
        final res = await _loanRepo.adminLoans();
        final list = (res['data'] as List<ApiLoan>? ?? []);
        final found = list.where((l) => l.id == id).firstOrNull;
        if (!mounted) return;
        setState(() {
          _loan = found;
          if (found != null) _codeController.text = found.code;
          _loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _searchError = 'Peminjaman tidak ditemukan.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _searchByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _searchError = null;
    });

    try {
      final loan = await _loanRepo.loanByCode(code);
      if (!mounted) return;
      setState(() {
        _loan = loan;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchError = 'Kode peminjaman "$code" tidak ditemukan.';
        _loan = null;
        _loading = false;
      });
    }
  }

  Future<void> _confirmReturn() async {
    if (_loan == null) return;

    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Konfirmasi Pengembalian',
      message: 'Konfirmasi pengembalian buku "${_loan!.book?.title ?? _loan!.code}"? Stok buku akan bertambah 1.',
      icon: Icons.assignment_return_outlined,
      confirmLabel: 'Ya, Kembalikan',
    );

    if (confirmed != true) return;

    try {
      final updated = await _loanRepo.returnLoan(_loan!.id);
      if (!mounted) return;
      showSnack(context, 'Pengembalian #${_loan!.code} berhasil dikonfirmasi');
      setState(() => _loan = updated);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal konfirmasi: ${e.toString().replaceAll("Exception: ", "")}', error: true);
    }
  }

  Future<void> _markFinePaid() async {
    if (_loan == null) return;

    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Konfirmasi Pembayaran Denda',
      message: 'Tandai denda peminjaman #${_loan!.code} (${_formatRupiah(_loan!.fineAmount)}) sudah lunas?',
      icon: Icons.payments_outlined,
      confirmLabel: 'Ya, Denda Lunas',
      accent: AppColors.success,
    );

    if (confirmed != true) return;

    try {
      final updated = await _loanRepo.payFine(_loan!.id);
      if (!mounted) return;
      showSnack(context, 'Denda #${_loan!.code} ditandai lunas.');
      setState(() => _loan = updated);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal menandai denda: ${e.toString().replaceAll("Exception: ", "")}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _loan;
    final book = p?.book;
    final user = p?.user;
    final dikembalikan = p?.status == 'returned';
    final dipinjam = p?.status == 'approved';
    final ditolak = p?.status == 'rejected';
    final menunggu = p?.status == 'pending';
    final late = p?.lateDays ?? 0;
    final denda = p?.fineAmount ?? 0;

    Color statusColor = AppColors.warn;
    String statusTitle = 'Sedang Dipinjam';
    String statusDesc = 'Menunggu konfirmasi pengembalian';
    IconData statusIcon = Icons.schedule;

    if (menunggu) {
      statusColor = AppColors.warn;
      statusTitle = 'Menunggu Persetujuan';
      statusDesc = 'Pengembalian belum dapat diproses sebelum disetujui.';
      statusIcon = Icons.hourglass_top;
    } else if (ditolak) {
      statusColor = AppColors.danger;
      statusTitle = 'Permohonan Ditolak';
      statusDesc = (p?.rejectedReason ?? '').isNotEmpty
          ? p!.rejectedReason!
          : 'Permohonan peminjaman tidak disetujui.';
      statusIcon = Icons.close;
    } else if (dikembalikan) {
      statusColor = AppColors.success;
      statusTitle = 'Sudah Dikembalikan';
      statusDesc = p?.returnedAt != null ? _formatTanggalJam(p!.returnedAt!) : '-';
      statusIcon = Icons.check;
    } else if (late > 0) {
      statusColor = AppColors.danger;
      statusTitle = 'Terlambat $late hari';
      statusDesc = 'Batas jatuh tempo terlewati';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        title: const Text('Pengembalian Buku'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Input kode peminjaman
          AdminCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cari Kode Pinjam',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: PJ25070101',
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                        onSubmitted: (_) => _searchByCode(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                      onPressed: _loading ? null : _searchByCode,
                      child: const Text('Cari'),
                    ),
                  ],
                ),
                if (_searchError != null) ...[
                  const SizedBox(height: 10),
                  Text(_searchError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (p != null) ...[
            AdminCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ItemThumbLarge(cover: book?.coverUrl ?? ''),
                  const SizedBox(height: 12),
                  Text(book?.title ?? 'Buku tidak ditemukan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text('Kode: #${p.code}', style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Peminjam: ${user?.name ?? '-'}${user?.nim == null ? '' : ' (${user!.nim})'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  Text(
                    'Diajukan: ${_formatTanggal(p.requestedAt)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  if (p.dueDate != null)
                    Text('Jatuh tempo: ${_formatTanggal(p.dueDate)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 16),
                  if (dipinjam)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.assignment_return),
                        onPressed: _confirmReturn,
                        label: const Text('Konfirmasi Pengembalian Buku'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Status Peminjaman',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 8),
            AdminCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    child: Icon(statusIcon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(statusTitle,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor)),
                        const SizedBox(height: 2),
                        Text(statusDesc,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (denda > 0) ...[
              const SizedBox(height: 16),
              const Text('Denda Keterlambatan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 8),
              AdminCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dikembalikan ? 'Total Denda' : 'Estimasi Denda Berjalan',
                          style: const TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                        Text(_formatRupiah(denda),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.danger)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$late hari keterlambatan × ${_formatRupiah(late > 0 ? denda / late : 0)}/hari',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                    if (dikembalikan) ...[
                      const SizedBox(height: 14),
                      if (p.finePaid)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: AppColors.success),
                            SizedBox(width: 6),
                            Text('Denda sudah lunas',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const Icon(Icons.payments_outlined),
                            onPressed: _markFinePaid,
                            label: const Text('Tandai Denda Lunas'),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: EmptyState(
                icon: Icons.search,
                message: 'Ketik kode peminjaman untuk memulai proses pengembalian buku.',
              ),
            ),
        ],
      ),
    );
  }

  String _formatTanggal(DateTime? d) {
    if (d == null) return '-';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  String _formatTanggalJam(DateTime d) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year}, $h:$m';
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
}

class ItemThumbLarge extends StatelessWidget {
  final String cover;
  const ItemThumbLarge({super.key, required this.cover});

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.menu_book, size: 64, color: AppColors.primary);
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.thumb,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: cover.trim().startsWith('http')
          ? Image.network(
              cover.trim(),
              fit: BoxFit.contain,
              errorBuilder: (_, error, stackTrace) => fallback,
            )
          : fallback,
    );
  }
}

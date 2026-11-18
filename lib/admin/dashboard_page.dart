import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'kategori_page.dart';
import 'models.dart';
import 'pengembalian_page.dart';
import '../../core/api/api_service.dart';
import '../../core/models/api_loan.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int> onSelectTab;
  const DashboardPage({super.key, required this.onSelectTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _stats = {};
  List<ApiLoan> _recent = [];
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
      final res = await _api.get('/admin/dashboard');
      final body = ApiService.decode(res);
      final data = (body['data'] ?? {}) as Map<String, dynamic>;
      final latestList = (data['latest_loans'] as List? ?? [])
          .map((e) => ApiLoan.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _stats = data;
        _recent = latestList;
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

  @override
  Widget build(BuildContext context) {
    final pendingCount = (_stats['pending_loans'] as num?)?.toInt() ?? 0;
    final activeCount = (_stats['active_loans'] as num?)?.toInt() ?? 0;
    final overdueCount = (_stats['overdue_loans'] as num?)?.toInt() ?? 0;
    final totalBooks = (_stats['total_books'] as num?)?.toInt() ?? 0;

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Perpustakaan MeTech',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              for (final e in const [
                [0, 'Dashboard', Icons.home_outlined],
                [1, 'Kelola Buku', Icons.menu_book_outlined],
                [2, 'Peminjaman', Icons.history],
                [3, 'Pengembalian', Icons.assignment_return_outlined],
                [4, 'Profil', Icons.person_outline],
              ])
                ListTile(
                  leading: Icon(e[2] as IconData, color: AppColors.primary),
                  title: Text(e[1] as String),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelectTab(e[0] as int);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.category_outlined, color: AppColors.primary),
                title: const Text('Kategori & User'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KategoriPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.menu, color: AppColors.text),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD9D9E3),
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Dashboard Admin',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 16),
                      OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.hourglass_top,
                        label: 'Menunggu',
                        value: pendingCount,
                        color: AppColors.warnBg,
                        textColor: AppColors.warn,
                        onTap: () => widget.onSelectTab(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book,
                        label: 'Sedang Dipinjam',
                        value: activeCount,
                        color: AppColors.primaryLight,
                        textColor: AppColors.primary,
                        onTap: () => widget.onSelectTab(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Terlambat',
                        value: overdueCount,
                        color: AppColors.dangerBg,
                        textColor: AppColors.danger,
                        onTap: () => widget.onSelectTab(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.library_books,
                        label: 'Judul Buku',
                        value: totalBooks,
                        color: AppColors.statBlue,
                        textColor: AppColors.primary,
                        onTap: () => widget.onSelectTab(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peminjaman Terbaru',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    InkWell(
                      onTap: () => widget.onSelectTab(2),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Row(children: [
                          Text('Lihat Semua',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_recent.isEmpty)
                  const SizedBox(height: 160, child: EmptyState(icon: Icons.history, message: 'Belum ada peminjaman.'))
                else
                  for (final p in _recent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AdminCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PengembalianPage(loanId: p.id)),
                        ),
                        child: Row(
                          children: [
                            ItemThumb(cover: p.book?.coverUrl ?? '', size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('#${p.code}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(p.book?.title ?? 'Buku',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.user?.name ?? '-'}${p.user?.nim == null ? '' : ' · ${p.user!.nim}'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                  ),
                                  Text('Diajukan ${_formatTanggal(p.requestedAt)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            StatusChip(status: _parseStatus(p.status), compact: true),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTanggal(DateTime? d) {
    if (d == null) return '-';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: textColor),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('$value',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/student/book_detail_page.dart';
import '../../features/student/book_list_page.dart';
import '../../features/student/home_page.dart';
import '../../features/student/loan_history_page.dart';
import '../../features/student/login_page.dart';
import '../../features/student/profile_page.dart';
import '../../features/student/student_shell.dart';
import '../../features/student/register_page.dart';
import '../../admin/admin_common.dart' show adminTheme;
import '../../admin/admin_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: '/admin',
      builder: (_, __) => Theme(data: adminTheme(), child: const AdminShell()),
    ),

    // Halaman dengan bottom nav (Beranda, Riwayat, Profil)
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => StudentShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/history', builder: (_, __) => const LoanHistoryPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ]),
      ],
    ),

    // Halaman fullscreen (tanpa bottom nav)
    GoRoute(path: '/books', builder: (_, __) => const BookListPage()),
    GoRoute(
      path: '/books/:id',
      builder: (_, state) => BookDetailPage(bookId: state.pathParameters['id']!),
    ),
  ],
);

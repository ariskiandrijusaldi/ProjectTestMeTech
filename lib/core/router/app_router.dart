import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/student/book_detail_page.dart';
import '../../features/student/book_list_page.dart';
import '../../features/student/home_page.dart';
import '../../features/student/loan_history_page.dart';
import '../../features/student/login_page.dart';
import '../../features/student/profile_page.dart';
import '../../features/student/register_page.dart';
import '../../features/student/student_shell.dart';
import '../../admin/admin_common.dart' show adminTheme;
import '../../admin/admin_shell.dart';
import '../auth/auth_provider.dart';

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      if (auth.isLoading) return null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!auth.isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      // Jika sudah login, jangan biarkan buka halaman login/register lagi
      if (isAuthRoute) {
        return auth.isAdmin ? '/admin' : '/home';
      }

      // Role-based access
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      if (isAdminRoute && !auth.isAdmin) {
        return '/home';
      }

      final isStudentRoute = state.matchedLocation == '/home' ||
          state.matchedLocation == '/history' ||
          state.matchedLocation == '/profile' ||
          state.matchedLocation == '/books' ||
          state.matchedLocation.startsWith('/books/');
      if (isStudentRoute && !auth.isMahasiswa) {
        return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),

      // Admin shell
      GoRoute(
        path: '/admin',
        builder: (context, state) => Theme(data: adminTheme(), child: const AdminShell()),
      ),

      // Student shell (bottom nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => StudentShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (context, state) => const LoanHistoryPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          ]),
        ],
      ),

      // Fullscreen pages
      GoRoute(path: '/books', builder: (context, state) => const BookListPage()),
      GoRoute(
        path: '/books/:id',
        builder: (context, state) => BookDetailPage(bookId: state.pathParameters['id']!),
      ),
    ],
  );
}

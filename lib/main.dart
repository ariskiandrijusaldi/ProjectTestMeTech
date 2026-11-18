import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: PerpustakaanApp(authProvider: authProvider),
    ),
  );
}

class PerpustakaanApp extends StatefulWidget {
  final AuthProvider? authProvider;
  const PerpustakaanApp({super.key, this.authProvider});

  @override
  State<PerpustakaanApp> createState() => _PerpustakaanAppState();
}

class _PerpustakaanAppState extends State<PerpustakaanApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = widget.authProvider ?? AuthProvider();
    _router = createAppRouter(auth);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Perpustakaan Kampus MeTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/supabase_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.initialize();
  // Trigger background sync with Supabase immediately
  unawaited(AppState.I.syncNow());
  runApp(const LimsApp());
}

class LimsApp extends StatelessWidget {
  const LimsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIMS — Branch Operations',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  String _stage = 'splash';
  String _role = 'branch';

  void _go(String stage, [String? role]) {
    setState(() {
      if (role != null) _role = role;
      _stage = stage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Center the phone-width UI on large screens (desktop browser).
    return Container(
      color: const Color(0xFFE9F1FD),
      alignment: Alignment.center,
      child: SizedBox(
        width: 430,
        child: _stageWidget(),
      ),
    );
  }

  Widget _stageWidget() {
    switch (_stage) {
      case 'welcome':
        return WelcomeScreen(onDone: () => _go('login'));
      case 'login':
        return LoginScreen(onDone: (role) => _go('main', role));
      case 'main':
        return MainShell(role: _role, onSignOut: () => _go('login'));
      default:
        return SplashScreen(onDone: () => _go('welcome'));
    }
  }
}

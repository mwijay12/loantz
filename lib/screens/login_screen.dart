import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  final void Function(String role) onDone;

  const LoginScreen({super.key, required this.onDone});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _role = 'branch';
  bool _busy = false;
  final _phone = TextEditingController(text: '+255 754 221 008');
  final _pwd = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _phone.dispose();
    _pwd.dispose();
    super.dispose();
  }

  void _switchRole(String r) {
    setState(() {
      _role = r;
      if (r == 'admin') {
        _phone.text = '+255 712 990 001';
      } else {
        _phone.text = '+255 754 221 008';
      }
    });
  }

  Future<void> _login() async {
    if (_busy) return;
    setState(() => _busy = true);

    final phoneInput = _phone.text.trim();
    final pwdInput = _pwd.text.trim();

    try {
      final supa = SupabaseService.instance;
      if (supa.isInitialized) {
        final profile = await supa.login(
          identifier: phoneInput,
          password: pwdInput,
        );

        if (profile != null) {
          final fullName = profile['full_name'] as String? ?? 'User';
          final userRole = profile['role'] as String? ?? _role;
          final branch = profile['branch_name'] as String? ?? 'Mbezi Branch';
          final phone = profile['phone'] as String? ?? phoneInput;
          final email = profile['email'] as String?;

          AppState.I.setUserProfile(
            fullName: fullName,
            userRole: userRole,
            branchName: branch,
            phone: phone,
            email: email,
          );

          if (!mounted) return;
          Toasts.show(context, 'Karibu, $fullName ($userRole)');
          widget.onDone(userRole);
          return;
        }
      }

      // Offline / Demo fallback
      final fallbackName = _role == 'admin' ? 'David Mwijage' : 'Neema Julius';
      final fallbackBranch = _role == 'admin' ? 'Headquarters (HQ)' : 'Mbezi Branch';
      AppState.I.setUserProfile(
        fullName: fallbackName,
        userRole: _role,
        branchName: fallbackBranch,
        phone: phoneInput,
      );

      if (!mounted) return;
      widget.onDone(_role);
    } catch (e) {
      if (!mounted) return;
      Toasts.show(context, e.toString().replaceAll('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: -80, left: -60, child: _blob(280, C.blue.withOpacity(.10))),
          Positioned(bottom: -60, right: -50, child: _blob(240, C.pink.withOpacity(.07))),
          Positioned(top: 60, right: -70, child: _blob(220, C.blue.withOpacity(.07))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: C.blueGrad,
                          boxShadow: [
                            BoxShadow(
                              color: C.blue.withOpacity(.35),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.view_in_ar_rounded,
                            size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text('LIMS',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Welcome back',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue to your branch workspace.',
                      style: TextStyle(fontSize: 13, color: C.muted)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [kShadow],
                    ),
                    child: Row(
                      children: [
                        _rolePill('Branch Staff', 'branch'),
                        _rolePill('Admin', 'admin'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _field(_phone, Icons.smartphone, 'Phone number', false),
                  const SizedBox(height: 12),
                  _field(_pwd, Icons.lock_outline_rounded, 'Password', true),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: true,
                              onChanged: (_) {},
                              activeColor: C.blue,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Remember me',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: C.muted)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Forgot password?',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: C.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    _busy ? 'Signing in…' : 'Log in to Branch App',
                    busy: _busy,
                    busyLabel: 'Signing in…',
                    onPressed: _login,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _login,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fingerprint, size: 20, color: C.blue),
                            SizedBox(width: 10),
                            Text('Sign in with Face ID',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: C.blue)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Demo build — tap Log in to enter the app',
                        style: TextStyle(
                            fontSize: 11,
                            color: C.faint,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _rolePill(String label, String role) {
    final on = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: on ? C.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: C.blue.withOpacity(.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : C.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, IconData icon, String hint,
      bool obscure) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [kShadow],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: C.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              obscuringCharacter: '•',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: C.faint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../pages/admin_console_page.dart';
import '../pages/home_page.dart';
import '../pages/inventory_page.dart';
import '../pages/loans_page.dart';
import '../pages/ops_pages.dart';
import '../pages/scan_page.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class MainShell extends StatefulWidget {
  final String role;
  final VoidCallback onSignOut;

  const MainShell({super.key, required this.role, required this.onSignOut});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    AppState.I.role = widget.role;
    AppState.I.startLoops();
  }

  void _setTab(int t) => setState(() => _tab = t);

  void _onOpen(String id) {
    switch (id) {
      case 'receive':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ReceivePage()));
        break;
      case 'transfer':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TransferPage()));
        break;
      case 'ai':
        openAiSheet(context);
        break;
      case 'admin_console':
        if (AppState.I.isAdmin) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminConsolePage()));
        } else {
          Toasts.show(
              context, 'Ruhusa ya Admin inahitajika (Admin access required)',
              error: true);
        }
        break;
      default:
        Toasts.show(context, 'Coming soon in this demo build');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: IndexedStack(
                  index: _tab,
                  children: [
                    HomePage(goTab: _setTab, onAI: () => openAiSheet(context)),
                    const InventoryPage(),
                    const ScanPage(),
                    const LoansPage(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 0,
              right: 0,
              child: Center(child: _syncPill(app)),
            ),
            Positioned(
              right: 16,
              bottom: 96,
              child: _aiFab(),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _nav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncPill(AppState app) => AnimatedBuilder(
        animation: app,
        builder: (bctx, _) {
          final busy = app.syncMode == SyncMode.busy;
          final off = app.syncMode == SyncMode.off;
          return GestureDetector(
            onTap: () {
              if (busy) return;
              app.syncNow();
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) Toasts.show(context, 'All data synced');
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [kShadowLg],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy)
                    const SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: C.blue),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: off ? C.pink : C.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 7),
                  Text(app.syncLabel,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                ],
              ),
            ),
          );
        },
      );

  Widget _aiFab() => GestureDetector(
        onTap: () => openAiSheet(context),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: C.violetGrad,
            boxShadow: [
              BoxShadow(
                color: C.violet.withOpacity(.4),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, size: 23, color: Colors.white),
        ),
      );

  Widget _nav() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [kShadowLg],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 66,
              color: Colors.white.withOpacity(.94),
              child: Row(
                children: [
                  _navItem(0, 'Home', Icons.home_outlined),
                  _navItem(1, 'Stock', Icons.inventory_2_outlined),
                  _scanFab(),
                  _navItem(3, 'Loans', Icons.favorite_border),
                  _moreBtn(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _navItem(int i, String label, IconData icon) {
    final sel = _tab == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _setTab(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: sel ? C.blue : const Color(0xFF9AA8BF)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: sel ? C.blue : const Color(0xFF9AA8BF))),
            const SizedBox(height: 2),
            sel
                ? Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: C.blue, shape: BoxShape.circle))
                : const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _scanFab() => SizedBox(
        width: 64,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -14),
            child: GestureDetector(
              onTap: () => _setTab(2),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: C.blueGrad,
                  boxShadow: [
                    BoxShadow(
                      color: C.blue.withOpacity(.42),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      );

  Widget _moreBtn() => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openMoreSheet(
            context,
            onOpen: _onOpen,
            onSignOut: widget.onSignOut,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.grid_view_rounded,
                  size: 22, color: Color(0xFF9AA8BF)),
              SizedBox(height: 3),
              Text('More',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9AA8BF))),
              SizedBox(height: 6),
            ],
          ),
        ),
      );
}

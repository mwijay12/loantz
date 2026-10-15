import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Shared sub-page header with back button.
Widget subHeader(BuildContext context, String title) => Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [kShadow],
            ),
            child:
                const Icon(Icons.chevron_left_rounded, size: 20, color: C.ink),
          ),
        ),
        Expanded(
          child: Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 40),
      ],
    );

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  double _progress = 0;
  bool _busy = false;
  Timer? _timer;

  static const _items = [
    ('iPhone 15 Pro Max', '×10', 'IP15PM-256-NT',
        [Color(0xFF1B6EF3), Color(0xFF0A49B8)]),
    ('Galaxy S24 Ultra', '×6', 'SGS24U-256-TG',
        [Color(0xFF6366F1), Color(0xFF4338CA)]),
    ('Redmi Note 13 Pro', '×8', 'RN13P-256-MB',
        [Color(0xFF0EA5E9), Color(0xFF0369A1)]),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _confirm() {
    if (_busy) return;
    setState(() => _busy = true);
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() => _progress = (_progress + 4 / 100).clamp(0.0, 1.0));
      if (_progress >= 1) {
        _timer?.cancel();
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await showSuccess(context,
        title: '24 units received',
        subtitle: 'Added to inventory · Value TZS 12.4M · PO #4521');
    if (!mounted) return;
    AppState.I.addActivity(ActivityItem(
      icon: Icons.download_rounded,
      colorKey: 'blue',
      title: 'Stock received — 24 units',
      detail: 'From Dar es Salaam Hub · PO #4521',
      time: AppState.I.nowLabel(),
    ));
    Toasts.show(context, '24 units received');
    setState(() {
      _busy = false;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            subHeader(context, 'Receive Stock'),
            const SizedBox(height: 16),
            LimsCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const IconBadge(
                      icon: Icons.download_rounded,
                      colorKey: 'blue',
                      size: 42,
                      iconSize: 20,
                      radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Dar es Salaam Hub',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                        Text('PO #4521 · Arrived 8:30 AM',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: C.muted,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 5),
                        AppBadge('24 units · TZS 12.4M', colorKey: 'blue'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LimsCard(
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) Container(height: 1, color: C.line),
                    _row(_items[i]),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
              child: LimsProgress(value: _progress),
            ),
            Text('${(_progress * 24).round()} of 24 units verified',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: C.muted)),
            const SizedBox(height: 16),
            PrimaryButton('Confirm Receive',
                busy: _busy, busyLabel: 'Receiving…', onPressed: _confirm),
          ],
        ),
      ),
    );
  }

  Widget _row((String, String, String, List<Color>) x) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: x.$4),
              ),
              child:
                  const Icon(Icons.smartphone, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(x.$1,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  Text('${x.$3} · ${x.$2}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: C.muted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                  color: C.greensoft, shape: BoxShape.circle),
              child:
                  const Icon(Icons.check_rounded, size: 13, color: C.green),
            ),
          ],
        ),
      );
}

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String _to = 'Kariakoo Branch';
  final List<int> _qty = [2, 3, 4];

  static const _dest = [
    ('Kariakoo Branch', 'Kariakoo'),
    ('Mwanza Branch', 'Mwanza'),
    ('Arusha Branch', 'Arusha'),
    ('Dodoma Branch', 'Dodoma'),
  ];

  static const _items = [
    ('iPhone 15', [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
    ('AirPods Pro (2nd Gen)', [Color(0xFFF472B6), Color(0xFFDB2777)]),
    ('Smart Watch X2', [Color(0xFFEC4899), Color(0xFFBE185D)]),
  ];

  void _send() {
    final total = _qty.fold<int>(0, (a, b) => a + b);
    Toasts.show(context, 'Transfer sent to $_to');
    AppState.I.addActivity(ActivityItem(
      icon: Icons.swap_horiz_rounded,
      colorKey: 'violet',
      title: 'Transfer sent — $total units',
      detail: 'To $_to',
      time: AppState.I.nowLabel(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            subHeader(context, 'Transfer Stock'),
            const SizedBox(height: 16),
            LimsCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: C.softer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: const [
                              Text('From',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: C.muted,
                                      fontWeight: FontWeight.w700)),
                              Text('Mbezi Branch',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.swap_horiz_rounded,
                            size: 18, color: C.blue),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: C.softer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              const Text('To',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: C.muted,
                                      fontWeight: FontWeight.w700)),
                              Text(_to,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final d in _dest)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _to = d.$1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _to == d.$1 ? C.blue : C.card,
                                  borderRadius: BorderRadius.circular(999),
                                  border: _to == d.$1
                                      ? null
                                      : Border.all(color: C.border),
                                ),
                                child: Text(d.$2,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _to == d.$1
                                            ? Colors.white
                                            : C.muted)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionLabel('Items to transfer'),
            LimsCard(
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) Container(height: 1, color: C.line),
                    _row(i),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton('Send Transfer', onPressed: _send),
          ],
        ),
      ),
    );
  }

  Widget _row(int i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _items[i].$2),
              ),
              child:
                  const Icon(Icons.smartphone, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_items[i].$1,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  const Text('Available: 12',
                      style: TextStyle(
                          fontSize: 10.5,
                          color: C.faint,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            _stepBtn('−', -1, i),
            SizedBox(
              width: 30,
              child: Text('${_qty[i]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            _stepBtn('+', 1, i),
          ],
        ),
      );

  Widget _stepBtn(String label, int delta, int i) => GestureDetector(
        onTap: () => setState(() => _qty[i] = (_qty[i] + delta).clamp(0, 20)),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: C.soft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: C.blue))),
        ),
      );
}

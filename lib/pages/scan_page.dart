import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_detail_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laser = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat(reverse: true);
  final _imeiCtrl = TextEditingController();
  final _rnd = Random();
  bool _scanning = false;
  bool _showManual = false;
  Product? _result;
  String _imei = '';
  String _status = 'Align the IMEI barcode within the frame';

  @override
  void dispose() {
    _laser.dispose();
    _imeiCtrl.dispose();
    super.dispose();
  }

  void _runScan() {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _result = null;
      _status = 'Scanning… detect IMEI barcode';
    });
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      final p = demoProducts[_rnd.nextInt(3)];
      final imei = '356789${100000000 + _rnd.nextInt(900000000)}';
      setState(() {
        _scanning = false;
        _result = p;
        _imei = imei;
        _status = 'IMEI verified · device found';
      });
      Toasts.show(context, 'IMEI verified · ${p.name}');
    });
  }

  void _reset() {
    setState(() {
      _scanning = false;
      _result = null;
      _showManual = false;
      _imeiCtrl.clear();
      _status = 'Align the IMEI barcode within the frame';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Branch Operations',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: C.muted,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Scan IMEI',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ],
            ),
            GestureDetector(
              onTap: () => setState(() => _showManual = !_showManual),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [kShadow],
                ),
                child: const Icon(Icons.keyboard_alt_outlined,
                    size: 20, color: C.ink),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _camera(),
        const SizedBox(height: 12),
        if (_result != null) ...[
          _resultCard(),
          const SizedBox(height: 12),
          PrimaryButton('Add to Sale', onPressed: () {
            final p = _result!;
            Toasts.show(context, 'Added to sale · ${fmtM(p.price)}');
            AppState.I.addActivity(ActivityItem(
              icon: Icons.payments_outlined,
              colorKey: 'green',
              title: 'Sale completed — ${p.name}',
              detail: '${fmtM(p.price)} · IMEI $_imei',
              time: AppState.I.nowLabel(),
            ));
            _reset();
          }),
          const SizedBox(height: 10),
          GhostButton(
            'View Product Details',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(productId: _result!.id))),
          ),
          Center(
            child: TextButton(
              onPressed: _reset,
              child: const Text('Scan another device',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: C.blue)),
            ),
          ),
        ] else ...[
          PrimaryButton('Simulate Scan', onPressed: _runScan),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showManual = true),
              child: const Text('Enter IMEI manually',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: C.blue)),
            ),
          ),
        ],
        if (_showManual) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imeiCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 15,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    filled: true,
                    fillColor: C.card,
                    hintText: 'Enter 15-digit IMEI',
                    hintStyle: const TextStyle(color: C.faint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: C.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: C.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_imeiCtrl.text.trim().length < 6) {
                    Toasts.show(context, 'Enter a valid 15-digit IMEI',
                        error: true);
                    return;
                  }
                  _runScan();
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.soft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Lookup',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: C.blue)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  Widget _camera() {
    return Container(
      height: 290,
      decoration: BoxDecoration(
        gradient: C.camGrad,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            const _Corner(alignment: Alignment.topLeft),
            const _Corner(alignment: Alignment.topRight),
            const _Corner(alignment: Alignment.bottomLeft),
            const _Corner(alignment: Alignment.bottomRight),
            AnimatedBuilder(
              animation: _laser,
              builder: (context, _) => Positioned(
                left: 46,
                right: 46,
                top: 46 + 186 * Curves.easeInOut.transform(_laser.value),
                child: Opacity(
                  opacity: _scanning ? 1 : 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Colors.transparent,
                        Color(0xFF5EA0FF),
                        Colors.transparent,
                      ]),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D8BFF).withOpacity(.8),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(_status,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    final p = _result!;
    final key =
        p.status == 'in' ? 'green' : p.status == 'low' ? 'pink' : 'gray';
    final txt = p.status == 'in'
        ? 'In Stock'
        : p.status == 'low'
            ? 'Low Stock'
            : 'Out of Stock';
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [kShadowLg],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: p.grad),
            ),
            child: const Icon(Icons.smartphone, size: 25, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                Text('IMEI $_imei',
                    style: const TextStyle(
                        fontSize: 11,
                        color: C.muted,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                AppBadge(txt, colorKey: key),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final bar = Colors.white.withOpacity(.8);
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Positioned(
      top: isTop ? 26.0 : null,
      bottom: !isTop ? 26.0 : null,
      left: isLeft ? 26.0 : null,
      right: !isLeft ? 26.0 : null,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          children: [
            Positioned(
              top: isTop ? 0.0 : null,
              bottom: !isTop ? 0.0 : null,
              left: 0,
              right: 0,
              child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                      color: bar, borderRadius: BorderRadius.circular(2))),
            ),
            Positioned(
              left: isLeft ? 0.0 : null,
              right: !isLeft ? 0.0 : null,
              top: 0,
              bottom: 0,
              child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                      color: bar, borderRadius: BorderRadius.circular(2))),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(.05)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onDone;

  const WelcomeScreen({super.key, required this.onDone});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _SlideData {
  final IconData icon;
  final IconData float1;
  final IconData float2;
  final String title;
  final String text;
  const _SlideData(this.icon, this.float1, this.float2, this.title, this.text);
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _slides = [
    _SlideData(Icons.view_in_ar_rounded, Icons.smartphone, Icons.favorite_border,
        'Every device, accounted for',
        'Live stock across all your branches, down to the last IMEI number.'),
    _SlideData(Icons.qr_code_scanner_rounded, Icons.qr_code_2, Icons.check_rounded,
        'Scan IMEI in seconds',
        'Verify devices, receive stock and close sales — all from the counter.'),
    _SlideData(Icons.favorite_border, Icons.credit_card_rounded, Icons.trending_up_rounded,
        'Loans without the chaos',
        'Track repayments, collections and dues with smart reminders.'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      widget.onDone();
    } else {
      _pc.animateToPage(_page + 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Welcome',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: widget.onDone,
                    child: const Text('Skip',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: C.muted)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Illustration(s),
                        const SizedBox(height: 30),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4)),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(s.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  color: C.muted,
                                  height: 1.6)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? C.blue : const Color(0xFFD3E0F4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _page > 0
                        ? GhostButton('Back',
                            onPressed: () => _pc.animateToPage(_page - 1,
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic))
                        : const SizedBox(),
                  ),
                  if (_page > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                        _page == _slides.length - 1 ? 'Get Started' : 'Next',
                        onPressed: _next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final _SlideData s;
  const _Illustration(this.s);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration:
                  const BoxDecoration(color: C.soft, shape: BoxShape.circle),
            ),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [kShadowLg],
                ),
                child: Icon(s.icon, size: 42, color: C.blue),
              ),
            ),
            Positioned(
                top: 14,
                right: 22,
                child: _Bob(
                    delay: Duration.zero, color: C.blue, icon: s.float1)),
            Positioned(
                bottom: 16,
                left: 20,
                child: _Bob(
                    delay: const Duration(milliseconds: 1200),
                    color: C.pink,
                    icon: s.float2)),
            Positioned(
                bottom: 34,
                right: 14,
                child: _Bob(
                    delay: const Duration(milliseconds: 600),
                    color: C.green,
                    icon: Icons.check_rounded)),
          ],
        ),
      );
}

class _Bob extends StatefulWidget {
  final Duration delay;
  final Color color;
  final IconData icon;

  const _Bob({required this.delay, required this.color, required this.icon});

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tri = 1 - (2 * _c.value - 1).abs();
    final t = Curves.easeInOut.transform(tri);
    return Transform.translate(
      offset: Offset(0, -8 * t),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [kShadow],
        ),
        child: Icon(widget.icon, size: 18, color: widget.color),
      ),
    );
  }
}

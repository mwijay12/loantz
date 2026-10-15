import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'ops_pages.dart';

class HomePage extends StatelessWidget {
  final void Function(int tab) goTab;
  final VoidCallback onAI;

  const HomePage({super.key, required this.goTab, required this.onAI});

  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Good morning',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: C.muted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    AppBadge(
                      app.isAdmin ? 'Admin' : 'Staff',
                      colorKey: app.isAdmin ? 'violet' : 'blue',
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(app.currentUserFullName,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ],
            ),
            Row(
              children: [
                _IconAction(
                  icon: Icons.notifications_none_rounded,
                  dot: true,
                  onTap: () => Toasts.show(context, '3 alerts need your attention',
                      error: true),
                ),
                const SizedBox(width: 10),
                UserAvatar(app.currentUserFullName),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [kShadow],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_outlined, size: 14, color: C.blue),
                const SizedBox(width: 6),
                Text('${app.currentBranchName} · ${app.isAdmin ? "All Access" : "Active Shift"}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded,
                    size: 14, color: Color(0xFFB7C3D6)),
              ],
            ),
          ),
        ),
        const SectionLabel("Today's Overview",
            margin: EdgeInsets.fromLTRB(2, 16, 2, 10)),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_outlined,
                colorKey: 'blue',
                label: 'Stock',
                value: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CountUp(app.totalStock),
                    const SizedBox(width: 4),
                    const Text('Phones',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: C.muted)),
                  ],
                ),
                trend: '+12 today',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.trending_up_rounded,
                colorKey: 'green',
                label: "Today's Sales",
                value: const CountUp(4.85, dec: 2, pre: 'TZS ', suf: 'M'),
                trend: '+12% vs yesterday',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.favorite_border,
                colorKey: 'pink',
                label: 'Active Loans',
                value: const CountUp(86),
                trend: '3 overdue',
                trendKind: 'down',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                colorKey: 'amber',
                label: 'Low Stock',
                value: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CountUp(app.lowCount),
                    const SizedBox(width: 4),
                    const Text('Models',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: C.muted)),
                  ],
                ),
                trend: 'Below minimum',
                trendKind: 'warn',
              ),
            ),
          ],
        ),
        const SectionLabel('Quick Actions',
            margin: EdgeInsets.fromLTRB(2, 16, 2, 10)),
        Row(
          children: [
            _QA(Icons.qr_code_scanner_rounded, 'blue', 'Scan', () => goTab(2)),
            _QA(Icons.credit_card_rounded, 'green', 'Sell', () {
              Toasts.show(context, 'Select a product to start a sale');
              goTab(1);
            }),
            _QA(Icons.download_rounded, 'violet', 'Receive', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReceivePage()));
            }),
            _QA(Icons.swap_horiz_rounded, 'amber', 'Transfer', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const TransferPage()));
            }),
          ],
        ),
        const SizedBox(height: 14),
        LimsCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Sales this week',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                  AppBadge('TZS 18.4M', colorKey: 'blue'),
                ],
              ),
              const SizedBox(height: 4),
              MiniBars(
                heights: const [.38, .52, .46, .68, .58, .86, .64],
                labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
              ),
            ],
          ),
        ),
        const SectionLabel('AI Assistant'),
        _aiCard(context),
        const SectionLabel('Recent Activity'),
        AnimatedBuilder(
          animation: app,
          builder: (_, __) => LimsCard(
            child: Column(
              children: [
                for (var i = 0; i < app.activity.length; i++) ...[
                  if (i > 0) Container(height: 1, color: C.line),
                  _ActRow(app.activity[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aiCard(BuildContext context) => GestureDetector(
        onTap: onAI,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: C.blueGrad),
            child: Stack(
              children: [
                Positioned(top: -70, right: -50, child: _circle(180, .10)),
                Positioned(bottom: -50, left: -30, child: _circle(110, .08)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome,
                                size: 19, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('LIMS AI Assistant',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              Text('Always online · replies instantly',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xCCFFFFFF))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask about stock levels, today’s sales, overdue loans or transfers.',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: Color(0xEBFFFFFF)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Try: Which phones are low on stock?',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: C.blue)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                size: 14, color: C.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final bool dot;
  final VoidCallback onTap;

  const _IconAction({required this.icon, this.dot = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [kShadow],
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 20, color: C.ink)),
              if (dot)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: C.pink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _QA extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final String label;
  final VoidCallback onTap;

  const _QA(this.icon, this.colorKey, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [kShadow],
            ),
            child: Column(
              children: [
                IconBadge(
                    icon: icon, colorKey: colorKey, size: 40, iconSize: 19, radius: 13),
                const SizedBox(height: 7),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}

class _ActRow extends StatelessWidget {
  final ActivityItem a;

  const _ActRow(this.a);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: a.icon, colorKey: a.colorKey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 1),
                  Text(a.detail,
                      style: const TextStyle(fontSize: 11, color: C.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(a.time,
                style: const TextStyle(
                    fontSize: 10.5,
                    color: C.faint,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}


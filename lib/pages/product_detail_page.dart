import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'ops_pages.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    final p = AppState.I.productById(widget.productId);
    if (p == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }
    final badgeKey =
        p.status == 'in' ? 'green' : p.status == 'low' ? 'pink' : 'gray';
    final badgeText = p.status == 'in'
        ? 'In Stock'
        : p.status == 'low'
            ? 'Low Stock'
            : 'Out of Stock';
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            Row(
              children: [
                _roundBtn(Icons.chevron_left_rounded,
                    () => Navigator.pop(context)),
                const Expanded(
                  child: Text('Product Details',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                AnimatedBuilder(
                  animation: AppState.I,
                  builder: (_, __) => _roundBtn(
                      p.fav ? Icons.favorite : Icons.favorite_border, () {
                    final wasFav = p.fav;
                    AppState.I.toggleFav(p.id);
                    Toasts.show(context,
                        wasFav ? 'Removed from favorites' : 'Added to favorites');
                  },
                      tint: p.fav ? C.pink : null,
                      bg: p.fav ? C.pinksoft : null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LimsCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: p.grad),
                    ),
                    child: const Icon(Icons.smartphone,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text('${p.sku} · ${p.variant}',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: C.muted,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 7),
                        AppBadge(badgeText, colorKey: badgeKey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _PdStat(fmtM(p.price), 'Retail price')),
                const SizedBox(width: 10),
                Expanded(child: _PdStat('${p.stock}', 'In stock')),
                const SizedBox(width: 10),
                Expanded(child: _PdStat('${p.onLoan}', 'On loan')),
              ],
            ),
            const SectionLabel('Inventory History'),
            LimsCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _Timeline(historyFor(p)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton('Sell this unit', onPressed: _sell),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: GhostButton('Transfer', onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TransferPage()));
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sell() {
    final p = AppState.I.productById(widget.productId);
    Toasts.show(context, 'Added to sale · counter ready');
    if (p != null) {
      AppState.I.addActivity(ActivityItem(
        icon: Icons.payments_outlined,
        colorKey: 'green',
        title: 'Sale completed — ${p.name}',
        detail: '${fmtM(p.price)} · Counter sale',
        time: AppState.I.nowLabel(),
      ));
    }
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap,
      {Color? tint, Color? bg}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg ?? C.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [kShadow],
        ),
        child: Icon(icon, size: 20, color: tint ?? C.ink),
      ),
    );
  }
}

class _PdStat extends StatelessWidget {
  final String value;
  final String label;

  const _PdStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [kShadow],
        ),
        child: Column(
          children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: C.muted, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _Timeline extends StatelessWidget {
  final List<HistoryEvent> events;

  const _Timeline(this.events);

  static const _typeIcons = {
    'receive': Icons.download_rounded,
    'sale': Icons.payments_outlined,
    'transfer': Icons.swap_horiz_rounded,
    'count': Icons.check_rounded,
    'alert': Icons.warning_amber_rounded,
  };

  String _key(String t) => t == 'sale'
      ? 'green'
      : t == 'transfer'
          ? 'violet'
          : t == 'alert'
              ? 'pink'
              : t == 'count'
                  ? 'gray'
                  : 'blue';

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var i = 0; i < events.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 20,
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: bgFor(_key(events[i].type)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_typeIcons[events[i].type],
                              size: 10, color: colorFor(_key(events[i].type))),
                        ),
                        if (i < events.length - 1)
                          Expanded(
                            child: Container(
                                width: 2, color: const Color(0xFFE6EFFB)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: i == events.length - 1 ? 2 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(events[i].title,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 1),
                          Text(events[i].detail,
                              style: const TextStyle(
                                  fontSize: 11.5, color: C.muted)),
                          const SizedBox(height: 2),
                          Text(events[i].time,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: C.faint,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
}

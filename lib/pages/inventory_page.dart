import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_detail_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _query = '';
  String _filter = 'all';

  static const _chips = [
    ('all', 'All'),
    ('phones', 'Phones'),
    ('acc', 'Accessories'),
    ('low', 'Low Stock'),
    ('loan', 'On Loan'),
  ];

  List<Product> _filtered() {
    final q = _query.toLowerCase();
    return AppState.I.products.where((p) {
      if (_filter == 'phones' && p.cat != 'phones') return false;
      if (_filter == 'acc' && p.cat != 'acc') return false;
      if (_filter == 'low' && !p.lowOrOut) return false;
      if (_filter == 'loan' && p.onLoan < 1) return false;
      if (q.isNotEmpty &&
          !(p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.I,
      builder: (context, _) {
        final items = _filtered();
        final units = items.fold<int>(0, (a, p) => a + p.stock);
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Mbezi Branch',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: C.muted,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('Inventory',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                  ],
                ),
                GestureDetector(
                  onTap: () =>
                      Toasts.show(context, '3 alerts need your attention',
                          error: true),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [kShadow],
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        size: 20, color: C.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [kShadow],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 17, color: C.muted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search phones, SKUs…',
                        hintStyle: TextStyle(color: C.faint),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (final c in _chips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Chip(
                        c.$2,
                        on: _filter == c.$1,
                        onTap: () => setState(() => _filter = c.$1),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
              child: Text('${items.length} models · $units units',
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: C.faint,
                      fontWeight: FontWeight.w600)),
            ),
            if (items.isEmpty)
              const LimsCard(
                padding: EdgeInsets.all(34),
                child: Center(
                  child: Text('No products match your search.',
                      style: TextStyle(
                          fontSize: 13,
                          color: C.muted,
                          fontWeight: FontWeight.w600)),
                ),
              )
            else
              ...items.map(_card),
          ],
        );
      },
    );
  }

  Widget _card(Product p) {
    final badgeKey =
        p.status == 'in' ? 'green' : p.status == 'low' ? 'pink' : 'gray';
    final badgeText = p.status == 'in'
        ? 'In Stock'
        : p.status == 'low'
            ? 'Low Stock'
            : 'Out of Stock';
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(productId: p.id))),
      child: Container(
        height: 78,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [kShadow],
        ),
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                        colors: p.grad,
                      ),
                    ),
                    child: const Icon(Icons.smartphone,
                        size: 25, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('${p.sku} · ${p.stock} in stock',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: C.muted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(fmtM(p.price),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        AppBadge(badgeText, colorKey: badgeKey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  final wasFav = p.fav;
                  AppState.I.toggleFav(p.id);
                  Toasts.show(context,
                      wasFav ? 'Removed from favorites' : 'Added to favorites');
                },
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: p.fav ? C.pinksoft : C.softer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p.fav ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: p.fav ? C.pink : const Color(0xFFC3CEDF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;

  const _Chip(this.label, {required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: on ? C.blue : C.card,
            borderRadius: BorderRadius.circular(999),
            border: on ? null : Border.all(color: C.border),
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
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : C.muted)),
        ),
      );
}

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  bool _pinging = false;
  String? _pingResult;

  Future<void> _pingSupabase() async {
    setState(() {
      _pinging = true;
      _pingResult = null;
    });

    final stopwatch = Stopwatch()..start();
    final ok = await SupabaseService.instance.pingKeepAlive();
    stopwatch.stop();

    if (!mounted) return;
    setState(() {
      _pinging = false;
      _pingResult = ok
          ? 'Active · ${stopwatch.elapsedMilliseconds}ms response'
          : 'Ping failed (check network)';
    });

    Toasts.show(
      context,
      ok ? 'Supabase Database kept active!' : 'Connection error',
      error: !ok,
    );
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add New Product',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _inputField(nameCtrl, 'Product Name (e.g. Galaxy Z Fold 6)'),
            const SizedBox(height: 10),
            _inputField(skuCtrl, 'SKU (e.g. GZF6-512-BK)'),
            const SizedBox(height: 10),
            _inputField(priceCtrl, 'Price in TZS (e.g. 4,200,000)'),
            const SizedBox(height: 10),
            _inputField(stockCtrl, 'Initial Stock Quantity', isNumber: true),
            const SizedBox(height: 18),
            PrimaryButton('Save to Supabase', onPressed: () async {
              if (nameCtrl.text.isEmpty || skuCtrl.text.isEmpty) {
                Toasts.show(ctx, 'Please fill in product name and SKU',
                    error: true);
                return;
              }
              Navigator.pop(ctx);
              try {
                final stock = int.tryParse(stockCtrl.text) ?? 10;
                await SupabaseService.instance.client.from('products').insert({
                  'name': nameCtrl.text.trim(),
                  'variant': 'Standard Edition',
                  'sku': skuCtrl.text.trim().toUpperCase(),
                  'price': priceCtrl.text.trim().isEmpty
                      ? '1,000,000'
                      : priceCtrl.text.trim(),
                  'stock': stock,
                  'min_stock': 5,
                  'category': 'phones',
                  'status': stock > 5 ? 'in' : (stock > 0 ? 'low' : 'out'),
                });
                await AppState.I.syncNow();
                if (mounted) {
                  Toasts.show(context, '${nameCtrl.text} added to inventory!');
                }
              } catch (e) {
                if (mounted) {
                  Toasts.show(context, 'Error adding product: $e', error: true);
                }
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: C.faint),
        filled: true,
        fillColor: C.softer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.I;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: C.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Admin Console',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: C.blue),
            tooltip: 'Add Product',
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Database & Keep-Alive Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [kShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Supabase Cloud Database',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const AppBadge('Live 24/7', colorKey: 'green'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Project Ref: fzlykkwgkydswvnlryhk (lims-loan-app)\nRegion: eu-central-1 (Frankfurt)',
                  style: TextStyle(fontSize: 12, color: C.muted, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pingResult ?? 'Keep-Alive: Active (Auto-ping scheduled)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _pingResult != null ? C.blue : C.faint,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _pinging ? null : _pingSupabase,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        side: const BorderSide(color: C.blue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _pinging
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Ping Now',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: C.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Branch Network Overview
          const SectionLabel('Regional Branch Network'),
          const SizedBox(height: 8),
          ...app.branches.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [kShadow],
                ),
                child: Row(
                  children: [
                    IconBadge(
                      icon: Icons.storefront_rounded,
                      colorKey: b.status == 'pink'
                          ? 'pink'
                          : (b.status == 'amber' ? 'amber' : 'blue'),
                      size: 40,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Sales: ${b.sales}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: C.muted,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    AppBadge(
                      '${b.low} low stock',
                      colorKey: b.low > 5 ? 'amber' : 'green',
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Staff Attendance Overview
          const SectionLabel('Staff & Shift Attendance'),
          const SizedBox(height: 8),
          ...app.staff.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [kShadow],
                ),
                child: Row(
                  children: [
                    UserAvatar(s.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(s.role,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: C.muted,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    AppBadge(
                      s.note.isNotEmpty ? s.note : s.status,
                      colorKey: s.status,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

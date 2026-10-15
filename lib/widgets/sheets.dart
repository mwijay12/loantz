import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../theme.dart';
import 'common.dart';

/// Opens the "Operations" bottom sheet.
void openMoreSheet(
  BuildContext context, {
  required void Function(String id) onOpen,
  required VoidCallback onSignOut,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MoreSheet(onOpen: onOpen, onSignOut: onSignOut),
  );
}

/// Opens the AI assistant chat sheet.
void openAiSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const AiSheet(),
    ),
  );
}

class MoreSheet extends StatelessWidget {
  final void Function(String id) onOpen;
  final VoidCallback onSignOut;

  const MoreSheet({super.key, required this.onOpen, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .86),
      decoration: const BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: C.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Operations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Text('Core branch workflows',
                style: TextStyle(
                    fontSize: 12, color: C.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Op(Icons.download_rounded, 'blue', 'Receive Stock',
                      'Verify shipments', () => onOpen('receive')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Op(Icons.swap_horiz_rounded, 'violet', 'Transfer',
                      'Between branches', () => onOpen('transfer')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Op(Icons.auto_awesome, 'violet', 'AI Assistant',
                      'Ask anything', () => onOpen('ai')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Op(Icons.schedule_rounded, 'green', 'Attendance',
                      'Clock in & out', () => onOpen('soon')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Op(Icons.bar_chart_rounded, 'pink', 'Reports',
                      'Sales & collections', () => onOpen('soon')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Op(Icons.shield_outlined, 'amber', 'Daily Close',
                      'Reconcile drawer', () => onOpen('soon')),
                ),
              ],
            ),
            const SectionLabel('Workspace'),
            _WRow(Icons.group_outlined, 'blue', 'Admin Console',
                () => onOpen('admin_console')),
            _WRow(Icons.settings_outlined, 'gray', 'Settings',
                () => onOpen('soon')),
            _WRow(Icons.logout_rounded, 'pink', 'Sign Out', onSignOut),
          ],
        ),
      ),
    );
  }
}

class _Op extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _Op(this.icon, this.colorKey, this.label, this.sub, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.softer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: icon, colorKey: colorKey, size: 38, iconSize: 18),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: C.muted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _WRow extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final String label;
  final VoidCallback onTap;

  const _WRow(this.icon, this.colorKey, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.softer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              IconBadge(icon: icon, colorKey: colorKey, size: 38, iconSize: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: Color(0xFFB7C3D6)),
            ],
          ),
        ),
      );
}

class _Msg {
  final bool isUser;
  final String text;
  _Msg(this.isUser, this.text);
}

class AiSheet extends StatefulWidget {
  const AiSheet({super.key});

  @override
  State<AiSheet> createState() => _AiSheetState();
}

class _AiSheetState extends State<AiSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg(false,
        "Hello Neema! I'm your ops assistant. I can check stock, summarize sales, flag overdue loans and more."),
  ];
  bool _waiting = false;

  static const _chips = [
    'Which phones are low on stock?',
    "Today's sales summary",
    'Overdue loans',
    'Total stock',
  ];

  void _send([String? preset]) {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _waiting) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_Msg(true, text));
      _waiting = true;
    });
    _toBottom();
    AiService.instance.ask(text).then((reply) {
      if (!mounted) return;
      setState(() {
        _waiting = false;
        _msgs.add(_Msg(false, reply));
      });
      _toBottom();
    });
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .86,
      decoration: const BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: C.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: C.violetGrad,
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LIMS Assistant',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: C.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        const Text('Online · replies instantly',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: C.green)),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: C.softer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.close_rounded, size: 18, color: C.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (final m in _msgs) _bubble(m),
                if (_waiting) const _Typing(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in _chips)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _send(c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: C.border),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: C.muted)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    filled: true,
                    fillColor: C.softer,
                    hintText: 'Ask about stock, loans, sales…',
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
                onTap: () => _send(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: C.blue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m) => Align(
        alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: m.isUser ? C.blue : C.softer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(m.isUser ? 16 : 5),
              bottomRight: Radius.circular(m.isUser ? 5 : 16),
            ),
          ),
          child: m.isUser
              ? Text(m.text,
                  style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: Colors.white))
              : Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: C.ink),
                    children: _spans(m.text),
                  ),
                ),
        ),
      );

  List<InlineSpan> _spans(String html) {
    final out = <InlineSpan>[];
    final re = RegExp(r'<b>(.*?)</b>|<br\s*/?>', dotAll: true);
    var i = 0;
    for (final m in re.allMatches(html)) {
      if (m.start > i) {
        out.add(TextSpan(text: _clean(html.substring(i, m.start))));
      }
      if (m.group(1) != null) {
        out.add(TextSpan(
            text: _clean(m.group(1)!),
            style: const TextStyle(fontWeight: FontWeight.w800)));
      } else {
        out.add(const TextSpan(text: '\n'));
      }
      i = m.end;
    }
    if (i < html.length) out.add(TextSpan(text: _clean(html.substring(i))));
    return out;
  }

  String _clean(String s) => s.replaceAll(RegExp(r'<[^>]+>'), '');
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _wave(double t, double phase) {
    final x = (t - phase) % 1.0;
    return x < 0.5 ? x * 2 : 2 - x * 2;
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: const BoxDecoration(
            color: C.softer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: 0.35 + 0.65 * _wave(_c.value, i * 0.33),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: C.faint, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}


import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

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
              children: const [
                Text('Collections',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: C.muted,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Active Loans',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ],
            ),
            GestureDetector(
              onTap: () => Toasts.show(context, 'New loan — select a customer'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [kShadow],
                ),
                child: const Icon(Icons.add, size: 20, color: C.ink),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                  icon: Icons.favorite_border,
                  colorKey: 'blue',
                  label: 'Active',
                  value: '86'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                  icon: Icons.schedule,
                  colorKey: 'amber',
                  label: 'Due this week',
                  value: '14'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                  icon: Icons.warning_amber_rounded,
                  colorKey: 'pink',
                  label: 'Overdue',
                  value: '3',
                  valueColor: C.pink),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...app.loans.map(_loanCard),
      ],
    );
  }

  Widget _loanCard(LoanAccount l) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [kShadow],
        ),
        child: Row(
          children: [
            UserAvatar(l.name, grad: l.grad, size: 38, radius: 12, font: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.name,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w800)),
                  Text(l.item,
                      style: const TextStyle(
                          fontSize: 11,
                          color: C.muted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  LimsProgress(value: l.paid / 100, height: 6),
                  const SizedBox(height: 4),
                  Text('${l.paid}% repaid',
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: C.faint,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fmtM(l.amount),
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                AppBadge(l.status == 'overdue' ? 'Overdue' : 'Current',
                    colorKey: l.status == 'overdue' ? 'pink' : 'green'),
                const SizedBox(height: 4),
                Text(l.due,
                    style: const TextStyle(
                        fontSize: 10.5,
                        color: C.faint,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniStat({
    required this.icon,
    required this.colorKey,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [kShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: icon, colorKey: colorKey, size: 38, iconSize: 19),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: C.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: valueColor ?? C.ink)),
          ],
        ),
      );
}

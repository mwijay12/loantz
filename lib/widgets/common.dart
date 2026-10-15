import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';

const kShadow = BoxShadow(
  color: Color(0x120F3478),
  blurRadius: 24,
  offset: Offset(0, 6),
);
const kShadowLg = BoxShadow(
  color: Color(0x210F3478),
  blurRadius: 40,
  offset: Offset(0, 16),
);

class LimsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const LimsCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [kShadow],
        ),
        child: child,
      );
}

class AppBadge extends StatelessWidget {
  final String text;
  final String colorKey;

  const AppBadge(this.text, {super.key, this.colorKey = 'green'});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: badgeBg(colorKey),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: badgeFg(colorKey),
          ),
        ),
      );
}

class SectionLabel extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry margin;

  const SectionLabel(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.margin = const EdgeInsets.fromLTRB(2, 20, 2, 10),
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: C.ink)),
            if (action != null)
              GestureDetector(
                onTap: onAction,
                child: Text(action!,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: C.blue)),
              ),
          ],
        ),
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final double size;
  final double iconSize;
  final double radius;

  const IconBadge({
    super.key,
    required this.icon,
    required this.colorKey,
    this.size = 36,
    this.iconSize = 16,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgFor(colorKey),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(icon, size: iconSize, color: colorFor(colorKey)),
      );
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String colorKey;
  final String label;
  final Widget value;
  final String? trend;
  final String trendKind;

  const StatCard({
    super.key,
    required this.icon,
    required this.colorKey,
    required this.label,
    required this.value,
    this.trend,
    this.trendKind = 'up',
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trendKind == 'down'
        ? C.pink
        : trendKind == 'warn'
            ? C.amber
            : C.green;
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [kShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, colorKey: colorKey, size: 38, iconSize: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: C.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                value,
                if (trend != null) ...[
                  const SizedBox(height: 3),
                  Text(trend!,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: trendColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CountUp extends StatelessWidget {
  final num target;
  final int dec;
  final String pre;
  final String suf;
  final TextStyle? style;

  const CountUp(
    this.target, {
    super.key,
    this.dec = 0,
    this.pre = '',
    this.suf = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          final txt =
              dec > 0 ? v.toStringAsFixed(dec) : fmtInt(v.round().toDouble());
          return Text(
            '$pre$txt$suf',
            style: style ??
                const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: C.ink,
                    height: 1.1),
          );
        },
      );
}

class MiniBars extends StatelessWidget {
  final List<double> heights;
  final List<String> labels;
  final int today;

  const MiniBars({
    super.key,
    required this.heights,
    required this.labels,
    this.today = 5,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < heights.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: (86 * heights[i]).clamp(8.0, 86.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: i == today ? null : const Color(0xFFD6E6FD),
                        gradient: i == today ? C.barGrad : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i],
                        style: const TextStyle(
                            fontSize: 10,
                            color: C.muted,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

class LimsProgress extends StatelessWidget {
  final double value;
  final double height;

  const LimsProgress({super.key, required this.value, this.height = 7});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Container(
          height: height,
          color: const Color(0xFFEAF1FB),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: C.progGrad,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      );
}

class UserAvatar extends StatelessWidget {
  final String name;
  final List<Color> grad;
  final double size;
  final double radius;
  final double font;

  const UserAvatar(
    this.name, {
    super.key,
    this.grad = const [Color(0xFF2E7BF5), C.blue2],
    this.size = 40,
    this.radius = 14,
    this.font = 13,
  });

  static String initials(String name) => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: grad,
          ),
          boxShadow: [
            BoxShadow(
              color: grad.first.withOpacity(.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          initials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: font,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final String? busyLabel;

  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.busy = false,
    this.busyLabel,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: C.blue.withOpacity(.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: C.blue,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: busy ? null : onPressed,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: busy
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(busyLabel ?? label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800)),
                      ],
                    )
                  : Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      );
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GhostButton(this.label, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Material(
        color: C.soft,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(label,
                style: const TextStyle(
                    color: C.blue, fontSize: 14, fontWeight: FontWeight.w800)),
          ),
        ),
      );
}

/// Lightweight toast system rendered above everything via the root Overlay.
class Toasts {
  static void show(BuildContext context, String msg, {bool error = false}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(msg: msg, error: error, onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  final String msg;
  final bool error;
  final VoidCallback onDone;

  const _ToastView({required this.msg, required this.error, required this.onDone});

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 2600), () async {
      await _c.reverse();
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_c.value);
          return Positioned(
            left: 0,
            right: 0,
            bottom: 110,
            child: IgnorePointer(
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - t)),
                  child: Center(child: child),
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: widget.error ? C.pink : C.dark,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [kShadowLg],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.error ? Icons.warning_amber_rounded : Icons.check_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(widget.msg,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
}

/// Full-screen success overlay (receive stock, daily close, …).
Future<void> showSuccess(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'success',
    barrierColor: const Color(0xF5F2F7FE),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                    color: C.greensoft, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 42, color: C.green),
              ),
              const SizedBox(height: 18),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: C.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                child: PrimaryButton('Done', onPressed: () => Navigator.of(ctx).pop()),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

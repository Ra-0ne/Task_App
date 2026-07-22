import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 140;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                vertical: compact ? 12 : 16,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(22),
                border: selected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: (gradient.colors.first).withValues(alpha: .35),
                    blurRadius: selected ? 22 : 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 38 : 46,
                    height: compact ? 38 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        color: Colors.white, size: compact ? 20 : 24),
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  _CountUp(value: count),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animates a number from its previous value to the new one.
class _CountUp extends StatefulWidget {
  final int value;
  const _CountUp({required this.value});

  @override
  State<_CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<_CountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<int> _anim;
  int _old = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _setup(widget.value);
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant _CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _old = oldWidget.value;
      _setup(widget.value);
      _c.forward(from: 0);
    }
  }

  void _setup(int target) {
    _anim = IntTween(begin: _old, end: target).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Text(
        '${_anim.value}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

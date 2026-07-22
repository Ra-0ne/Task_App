import 'package:flutter/material.dart';

class StatusSection extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const StatusSection({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  static const _options = <_StatusOption>[
    _StatusOption(
      title: 'Pending',
      icon: Icons.radio_button_unchecked_rounded,
      color: Color(0xFFF59E0B),
    ),
    _StatusOption(
      title: 'Completed',
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF10B981),
    ),
    _StatusOption(
      title: 'Overdue',
      icon: Icons.error_outline_rounded,
      color: Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row: icon + title
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffF2EEFF), Color(0xffE5DEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_circle_outlined,
                  color: Color(0xff6C63FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Tap to choose',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Compact status chips in a Wrap
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((opt) {
              final selected = selectedStatus == opt.title;
              return _StatusChip(
                option: opt,
                selected: selected,
                onTap: () => onChanged(opt.title),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusOption {
  final String title;
  final IconData icon;
  final Color color;
  const _StatusOption({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _StatusChip extends StatelessWidget {
  final _StatusOption option;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? option.color : option.color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? option.color : option.color.withValues(alpha: .3),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: .3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              color: selected ? Colors.white : option.color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              option.title,
              style: TextStyle(
                color: selected ? Colors.white : option.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(Icons.check_rounded,
                      key: ValueKey(option.title),
                      color: Colors.white,
                      size: 16)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

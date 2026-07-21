import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';

/// Horizontal scrollable filter chips: All / Pending / Completed / Overdue.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  static const _filters = TaskStatusFilter.values;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final active = provider.statusFilter;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == active;
          return _AnimatedChip(
            label: filter.label,
            selected: selected,
            onTap: () => provider.setStatusFilter(filter),
          );
        },
      ),
    );
  }
}

class _AnimatedChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AnimatedChip({
    required this.label,
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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xff6C63FF), Color(0xff8B7BFF)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xff6C63FF).withValues(alpha: .35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: selected ? Colors.white : textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

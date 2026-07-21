import 'package:flutter/material.dart';
import 'package:task_app/utils/app_colors.dart';

class StatusSection extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const StatusSection({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          /// Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffF2EEFF), Color(0xffE5DEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.flag_circle_outlined,
              color: Color(0xff6C63FF),
              size: 26,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Status",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Select task status",
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 18),

          _StatusItem(
            title: "Pending",
            icon: Icons.radio_button_unchecked,
            iconColor: iconColor,
            selected: selectedStatus == "Pending",
            onTap: () => onChanged("Pending"),
          ),

          const SizedBox(height: 12),

          _StatusItem(
            title: "Completed",
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            selected: selectedStatus == "Completed",
            onTap: () => onChanged("Completed"),
          ),

          const SizedBox(height: 12),

          _StatusItem(
            title: "Overdue",
            icon: Icons.error_outline,
            iconColor: Colors.red,
            selected: selectedStatus == "Overdue",
            onTap: () => onChanged("Overdue"),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _StatusItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffF3F0FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xff6C63FF)
                : const Color(0xffE5E5E5),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xff6C63FF)
                      : Colors.black87,
                ),
              ),
            ),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle,
                color: Color(0xff6C63FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
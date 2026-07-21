import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final int index;

  const TaskItem({super.key, required this.task, this.index = 0});

  Color _statusColor() {
    switch (task.status) {
      case TaskStatus.completed:
        return const Color(0xFF10B981);
      case TaskStatus.overdue:
        return const Color(0xFFEF4444);
      case TaskStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon() {
    switch (task.status) {
      case TaskStatus.completed:
        return Icons.check_circle_rounded;
      case TaskStatus.overdue:
        return Icons.error_outline_rounded;
      case TaskStatus.pending:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _statusLabel() => task.status.label;

  Future<bool?> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Task'),
          ],
        ),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final provider = context.read<TaskProvider>();
      provider.deleteTask(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${task.title}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => provider.restoreTask(task),
          ),
        ),
      );
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final statusColor = _statusColor();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 60).clamp(0, 240)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: Hero(
        tag: 'task-${task.id}',
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 26),
                  SizedBox(height: 4),
                  Text('Delete',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
            confirmDismiss: (_) => _confirmDelete(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: statusColor.withValues(alpha: .25), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editTask,
                  arguments: EditTaskArgs(task),
                ),
                borderRadius: BorderRadius.circular(18),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StatusToggle(
                                    color: statusColor,
                                    icon: _statusIcon(),
                                    onTap: () => provider.toggleStatus(task.id),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            decoration:
                                                task.status ==
                                                        TaskStatus.completed
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            color: task.status ==
                                                    TaskStatus.completed
                                                ? Colors.grey
                                                : textPrimary,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.grey, size: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.editTask,
                                          arguments: EditTaskArgs(task),
                                        );
                                      } else if (value == 'delete') {
                                        _confirmDelete(context);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [
                                          Icon(Icons.edit_outlined, size: 20),
                                          SizedBox(width: 10),
                                          Text('Edit'),
                                        ]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete_outline,
                                              color: Colors.red, size: 20),
                                          SizedBox(width: 10),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _Chip(
                                      color: task.categoryColor,
                                      label: task.category),
                                  const SizedBox(width: 8),
                                  _Chip(
                                      color: statusColor,
                                      label: _statusLabel()),
                                  const Spacer(),
                                  Icon(Icons.schedule_outlined,
                                      size: 14,
                                      color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.time,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated status toggle button — rotates / scales on tap.
class _StatusToggle extends StatefulWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _StatusToggle(
      {required this.color, required this.icon, required this.onTap});

  @override
  State<_StatusToggle> createState() => _StatusToggleState();
}

class _StatusToggleState extends State<_StatusToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _c.forward(from: 0.0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _c,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (_, _, child) => child!,
          child: Icon(widget.icon, color: widget.color, size: 28),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;
  const _Chip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

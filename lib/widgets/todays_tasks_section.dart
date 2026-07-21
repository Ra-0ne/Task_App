import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/task_item.dart';
import 'package:task_app/utils/app_colors.dart';
import 'package:task_app/utils/responsive.dart';

class TodayTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  const TodayTasksSection({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridColumns(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cols > 1 ? 'All Tasks' : "Today's Tasks",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(tasks.length),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xff6C63FF).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      color: Color(0xff6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: tasks.isEmpty
                ? _EmptyState(key: const ValueKey('empty'))
                : _TaskGrid(
                    key: ValueKey('grid-$cols-${tasks.length}'),
                    tasks: tasks,
                    cols: cols,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskGrid extends StatelessWidget {
  final List<TaskModel> tasks;
  final int cols;
  const _TaskGrid({super.key, required this.tasks, required this.cols});

  @override
  Widget build(BuildContext context) {
    if (cols == 1) {
      return Column(
        children: List.generate(
          tasks.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskItem(task: tasks[i], index: i),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (cols - 1) * spacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tasks
              .map((t) => SizedBox(
                    width: itemWidth,
                    child: TaskItem(task: t, index: tasks.indexOf(t)),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xff6C63FF).withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 44,
                  color: Color(0xff6C63FF),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap "New Task" to add your first one',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

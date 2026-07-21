import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          task.status == TaskStatus.completed
              ? Icons.check_circle
              : task.status == TaskStatus.overdue
              ? Icons.error_outline
              : Icons.radio_button_unchecked,
          color: task.status == TaskStatus.completed
              ? Colors.green
              : task.status == TaskStatus.overdue
              ? Colors.red
              : Colors.grey,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: task.categoryColor),

                  const SizedBox(width: 6),

                  Text(
                    task.category,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),

        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 18,
              color: task.status == TaskStatus.overdue
                  ? Colors.red
                  : Colors.grey,
            ),

            const SizedBox(width: 6),

            Text(
              task.time,
              style: TextStyle(
                color: task.status == TaskStatus.overdue
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

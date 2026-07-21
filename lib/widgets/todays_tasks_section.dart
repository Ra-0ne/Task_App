import 'package:flutter/material.dart';
import 'package:task_app/data/dummy_data.dart';
import 'package:task_app/widgets/task_item.dart';
import 'package:task_app/utils/app_colors.dart';
import 'package:task_app/models/task_model.dart';


class TodayTasksSection extends StatelessWidget {
final List<TaskModel> tasks;

  const TodayTasksSection({super.key, required this.tasks});
  @override
  Widget build(BuildContext context) {
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
              const Text(
                "Today's Tasks",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          tasks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No tasks for today yet!",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              :ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayTasks.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 28,
                ),
                itemBuilder: (context, index) {
                  return TaskItem(
                    task: todayTasks[index],
                  );
                },
              ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart'; 
import 'package:task_app/models/task_model.dart';
import 'package:task_app/services/database_service.dart';
import 'package:task_app/widgets/app_bar_widget.dart';
import 'package:task_app/utils/app_padding.dart';
import 'package:task_app/utils/app_colors.dart';
import 'package:task_app/widgets/search_bar_widget.dart';
import 'package:task_app/widgets/statistic_card.dart';
import 'package:task_app/widgets/todays_tasks_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: whiteCards,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: AppPadding.screen,
                child: ValueListenableBuilder(
                  // الاستماع للدالة الصحيحةgetBox المتوافقة مع نوع الـ Map المخزن
                  valueListenable: DatabaseService.getBox().listenable(),
                  builder: (context, Box<Map> box, _) {
                    // تحويل الـ Maps المخزنة ديناميكياً داخل الـ Builder إلى List<TaskModel>
                    final tasks = box.values
                        .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
                        .toList();

                    // حساب الإحصائيات ديناميكياً من قائمة الـ Objects الجديدة
                    final allTasksCount = tasks.length;
                    final pendingCount = tasks.where((t) => t.status == TaskStatus.pending).length;
                    final completedCount = tasks.where((t) => t.status == TaskStatus.completed).length;
                    final overdueCount = tasks.where((t) => t.status == TaskStatus.overdue).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBarWidget(),
                        const SizedBox(height: 10),
                        const Text(
                          'Good Morning, Rawan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Let's get things done today!",
                          style: TextStyle(fontSize: 16, color: textSecondary),
                        ),
                        const SizedBox(height: 20),
                        const SearchBarWidget(),
                        const SizedBox(height: 10),
                        
                        /// قسم كروت الإحصائيات الديناميكية
                        SizedBox(
                          height: 180,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                DashboardCard(
                                  icon: Icons.assignment_outlined,
                                  color: const Color(0xff6C63FF),
                                  title: "All Tasks",
                                  count: allTasksCount.toString(),
                                ),
                                const SizedBox(width: 10),
                                DashboardCard(
                                  icon: Icons.access_time_rounded,
                                  color: const Color(0xffF59E0B),
                                  title: "Pending",
                                  count: pendingCount.toString(),
                                ),
                                const SizedBox(width: 10),
                                DashboardCard(
                                  icon: Icons.check_circle_outline_rounded,
                                  color: const Color(0xff10B981),
                                  title: "Completed",
                                  count: completedCount.toString(),
                                ),
                                const SizedBox(width: 10),
                                DashboardCard(
                                  icon: Icons.flag_outlined,
                                  color: const Color(0xffEF4444),
                                  title: "Overdue",
                                  count: overdueCount.toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        /// قسم عرض القائمة الحقيقية وتمرير القائمة المحولة لها
                        TodayTasksSection(tasks: tasks),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
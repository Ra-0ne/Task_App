import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/animated_fab.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/statistic_card.dart';
import '../widgets/todays_tasks_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padH = Responsive.screenPadding(context);

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true,
      floatingActionButton: const AnimatedFab(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          /// Gradient header (collapsing app bar)
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.header),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padH, 8, padH, 0),
                    child: const AppBarWidget(),
                  ),
                ),
              ),
            ),
          ),

          /// Body — everything scrolls together (filter chips included)
          SliverToBoxAdapter(
            child: CenteredConstrained(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, 8, padH, 96),
                child: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Greeting
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Let's get things done today!",
                                style: TextStyle(
                                    fontSize: 15, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SearchBarWidget(),
                        const SizedBox(height: 14),

                        /// Filter chips — scroll with the content
                        const FilterChipsRow(),
                        const SizedBox(height: 18),

                        /// Stat cards grid — responsive
                        _StatGrid(provider: provider),
                        const SizedBox(height: 22),

                        /// Task list section (also responsive)
                        TodayTasksSection(tasks: provider.filteredTasks),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning, Rawan';
    if (h < 17) return 'Good Afternoon, Rawan';
    return 'Good Evening, Rawan';
  }
}

class _StatGrid extends StatelessWidget {
  final TaskProvider provider;
  const _StatGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.statColumns(context);

    final cards = <DashboardCard>[
      DashboardCard(
        icon: Icons.assignment_outlined,
        gradient: AppGradients.accentPurple,
        title: 'All Tasks',
        count: provider.allCount,
        selected: provider.statusFilter == TaskStatusFilter.all,
        onTap: () => provider.setStatusFilter(TaskStatusFilter.all),
      ),
      DashboardCard(
        icon: Icons.access_time_rounded,
        gradient: AppGradients.accentAmber,
        title: 'Pending',
        count: provider.pendingCount,
        selected: provider.statusFilter == TaskStatusFilter.pending,
        onTap: () => provider.setStatusFilter(TaskStatusFilter.pending),
      ),
      DashboardCard(
        icon: Icons.check_circle_outline_rounded,
        gradient: AppGradients.accentGreen,
        title: 'Completed',
        count: provider.completedCount,
        selected: provider.statusFilter == TaskStatusFilter.completed,
        onTap: () => provider.setStatusFilter(TaskStatusFilter.completed),
      ),
      DashboardCard(
        icon: Icons.flag_outlined,
        gradient: AppGradients.accentRed,
        title: 'Overdue',
        count: provider.overdueCount,
        selected: provider.statusFilter == TaskStatusFilter.overdue,
        onTap: () => provider.setStatusFilter(TaskStatusFilter.overdue),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              cards.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
        );
      },
    );
  }
}

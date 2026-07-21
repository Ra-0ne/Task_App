import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_task_screen.dart';

/// Centralised named-route definitions.
class AppRoutes {
  const AppRoutes._();

  static const String dashboard = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
}

/// Optional payload used by [AppRoutes.editTask].
class EditTaskArgs {
  final TaskModel task;
  const EditTaskArgs(this.task);
}

/// Generates pages with a smooth fade + slide-up transition.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.dashboard:
      return _buildRoute(const DashboardScreen(), settings);
    case AppRoutes.addTask:
      return _buildRoute(const AddTaskScreen(), settings);
    case AppRoutes.editTask:
      final args = settings.arguments;
      final screen = args is EditTaskArgs
          ? AddTaskScreen(task: args.task)
          : const AddTaskScreen();
      return _buildRoute(screen, settings);
    default:
      return _buildRoute(const DashboardScreen(), settings);
  }
}

PageRouteBuilder _buildRoute(Widget screen, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => screen,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

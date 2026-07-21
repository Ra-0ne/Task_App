import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

/// Single source of truth for the tasks list.
///
/// The UI reads from this provider via `Consumer` / `context.watch` and
/// mutates state via the public methods. Every mutation:
///   1. writes to Hive (persistent storage) and
///   2. updates the in-memory list and calls `notifyListeners()`.
class TaskProvider extends ChangeNotifier {
  TaskProvider() {
    // Load synchronously so the first build reads the real counts.
    // Do NOT call notifyListeners() here — no widget is listening yet
    // during construction, so the call would be lost.
    _tasks = DatabaseService.getAllTasks()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<TaskModel> _tasks = [];
  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  List<TaskModel> get tasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskStatusFilter get statusFilter => _statusFilter;

  /// Tasks filtered by the current search query AND the active status filter.
  List<TaskModel> get filteredTasks {
    var result = _tasks;

    if (_statusFilter != TaskStatusFilter.all) {
      final target = _statusFilter.toStatus();
      result = result.where((t) => t.status == target).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.category.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }

    return List.unmodifiable(result);
  }

  // ---------------------------------------------------------------------------
  // Computed statistics (used by the dashboard cards)
  // ---------------------------------------------------------------------------

  int get allCount => _tasks.length;
  int get pendingCount =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get completedCount =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get overdueCount =>
      _tasks.where((t) => t.status == TaskStatus.overdue).length;

  // ---------------------------------------------------------------------------
  // Hive hydration (reload from storage, e.g. after external changes)
  // ---------------------------------------------------------------------------

  void reloadFromHive() {
    _tasks = DatabaseService.getAllTasks()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required Color categoryColor,
    required TaskStatus status,
  }) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category.isEmpty ? 'General' : category,
      categoryColor: categoryColor,
      time: DateFormat('h:mm a').format(now),
      status: status,
      createdAt: now,
    );
    await DatabaseService.addTask(task);
    _tasks.insert(0, task);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  Future<void> updateTask(TaskModel updated) async {
    await DatabaseService.updateTask(updated);
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
    }
  }

  /// Toggles between [pending] and [completed] for quick check-off.
  Future<void> toggleStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    final updated = task.copyWith(status: newStatus);
    await DatabaseService.updateTask(updated);
    _tasks[index] = updated;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks.removeAt(index);
    await DatabaseService.deleteTask(id);
    notifyListeners();
  }

  /// Restores the most recently deleted task — handy for an undo SnackBar.
  Future<void> restoreTask(TaskModel task) async {
    await DatabaseService.addTask(task);
    _tasks.insert(0, task);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // STATUS FILTER
  // ---------------------------------------------------------------------------

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }
}

/// Filter chip values shown above the tasks list.
enum TaskStatusFilter { all, pending, completed, overdue }

extension TaskStatusFilterX on TaskStatusFilter {
  String get label {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.completed:
        return 'Completed';
      case TaskStatusFilter.overdue:
        return 'Overdue';
    }
  }

  TaskStatus toStatus() {
    switch (this) {
      case TaskStatusFilter.pending:
        return TaskStatus.pending;
      case TaskStatusFilter.completed:
        return TaskStatus.completed;
      case TaskStatusFilter.overdue:
        return TaskStatus.overdue;
      case TaskStatusFilter.all:
        return TaskStatus.pending; // unused for 'all'
    }
  }
}

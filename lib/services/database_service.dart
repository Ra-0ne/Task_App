import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import '../models/task_model.dart';

/// Thin, stateless wrapper around the Hive box that persists [TaskModel]s.
///
/// The UI should NOT talk to Hive directly — it goes through [TaskProvider],
/// which in turn calls this service. This keeps the data layer swappable
/// (e.g. we could later replace Hive with SQLite without touching the UI).
class DatabaseService {
  const DatabaseService._();

  static const String boxName = 'tasks_box';

  /// Opens the box. Called once at app start in `main.dart`.
  ///
  /// On the very first launch the box is empty, so we seed it with a few
  /// sample tasks so the dashboard isn't blank with all counts at 0.
  static Future<Box<Map>> openBox() async {
    final Box<Map> box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<Map>(boxName);
    } else {
      box = await Hive.openBox<Map>(boxName);
    }

    if (box.isEmpty) {
      await _seedSampleTasks(box);
    }

    return box;
  }

  static Box<Map> get box => Hive.box<Map>(boxName);

  /// Populates the box with sample tasks the first time the app runs.
  static Future<void> _seedSampleTasks(Box<Map> box) async {
    final now = DateTime.now();
    final samples = <TaskModel>[
      TaskModel(
        id: 'sample-1',
        title: 'UI Design',
        description: 'Design the login and dashboard screens',
        category: 'Design',
        categoryColor: Colors.purple,
        time: '10:00 AM',
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TaskModel(
        id: 'sample-2',
        title: 'Flutter Dashboard',
        description: 'Build the dashboard with stat cards and task list',
        category: 'Development',
        categoryColor: Colors.blue,
        time: '1:00 PM',
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      TaskModel(
        id: 'sample-3',
        title: 'API Integration',
        description: 'Connect the app to the backend REST API',
        category: 'Backend',
        categoryColor: Colors.orange,
        time: '2:00 PM',
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TaskModel(
        id: 'sample-4',
        title: 'Team Meeting',
        description: 'Weekly sync with the product team',
        category: 'Meeting',
        categoryColor: Colors.teal,
        time: '4:30 PM',
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: 'sample-5',
        title: 'Update Documentation',
        description: 'Update the README with new setup steps',
        category: 'Documentation',
        categoryColor: Colors.red,
        time: 'Yesterday',
        status: TaskStatus.overdue,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final t in samples) {
      await box.put(t.id, t.toMap());
    }
  }

  // ---------- CREATE ----------
  static Future<void> addTask(TaskModel task) async {
    await box.put(task.id, task.toMap());
  }

  // ---------- READ ----------
  static List<TaskModel> getAllTasks() {
    return box.values
        .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ---------- UPDATE ----------
  static Future<void> updateTask(TaskModel task) async {
    await box.put(task.id, task.toMap());
  }

  // ---------- DELETE ----------
  static Future<void> deleteTask(String id) async {
    await box.delete(id);
  }
}

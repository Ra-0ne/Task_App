import 'package:hive_ce/hive.dart';
import '../models/task_model.dart'; 

class DatabaseService {
  static const String _boxName = 'tasks_box';

  // جعل الدالة عامة (بدون سكور) لتتمكني من استدعائها في الـ Dashboard
  // وتحديد نوعها كمستقبل لـ Map (لأنكِ تخزنين task.toMap())
  static Box<Map> getBox() => Hive.box<Map>(_boxName);

  // [CREATE] - إضافة مهمة جديدة
  static Future<void> addTask(TaskModel task) async {
    await getBox().put(task.id, task.toMap());
  }

  // [READ] - جلب كل المهام المخزنة وتحويلها إلى List<TaskModel>
  static List<TaskModel> getAllTasks() {
    final box = getBox();
    // نقوم بتحويل كل الخرائط (Maps) المخزنة إلى Object الخاص بكِ
    return box.values.map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  // [UPDATE] - تعديل مهمة بالكامل أو حالتها
  static Future<void> updateTask(TaskModel task) async {
    await getBox().put(task.id, task.toMap());
  }

  // [DELETE] - حذف مهمة باستخدام الـ id
  static Future<void> deleteTask(String id) async {
    await getBox().delete(id);
  }
}
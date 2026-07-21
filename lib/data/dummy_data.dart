import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';

  List<TaskModel> todayTasks = [
  TaskModel(
    id: "1",
    title: "UI Design",
    category: "Design",
    categoryColor: Colors.purple,
    time: "10:00 AM",
    status: TaskStatus.completed,
  ),

  TaskModel(
    id: "2",
    title: "Flutter Dashboard",
    category: "Development",
    categoryColor: Colors.blue,
    time: "1:00 PM",
    status: TaskStatus.pending,
  ),

  TaskModel(
    id: "3",
    title: "API Integration",
    category: "Backend",
    categoryColor: Colors.orange,
    time: "02:00 PM",
    status: TaskStatus.pending,
  ),

  TaskModel(
    id: "4",
    title: "Team Meeting",
    category: "Meeting",
    categoryColor: Colors.teal,
    time: "04:30 PM",
    status: TaskStatus.completed,
  ),

  TaskModel(
    id: "5",
    title: "Update Documentation",
    category: "Documentation",
    categoryColor: Colors.red,
    time: "Yesterday",
    status: TaskStatus.overdue,
  ),
];

import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  completed,
  overdue,
}

class TaskModel {
  final String id;
  final String title;
  final String category;
  final Color categoryColor;
  final String time;
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.time,
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'categoryColor': categoryColor.value, 
      'time': time,
      'status': status.name, 
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      categoryColor: Color(map['categoryColor']),
      time: map['time'],
      status: TaskStatus.values.byName(map['status']), 
    );
  }
}
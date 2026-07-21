import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart'; 
import 'package:task_app/services/database_service.dart';
import 'package:task_app/utils/app_colors.dart';
import 'package:task_app/utils/app_padding.dart';
import 'package:task_app/widgets/status_section.dart';
import 'package:task_app/widgets/task_input_card.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  String selectedStatus = "Pending";
  bool autoValidate = false;
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  TaskStatus _getTaskStatusEnum(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'overdue':
        return TaskStatus.overdue;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  Color _getCategoryColor(String category) {
    if (category.trim().isEmpty) return Colors.grey;
    switch (category.toLowerCase()) {
      case 'design': return Colors.purple;
      case 'development': return Colors.blue;
      case 'backend': return Colors.orange;
      case 'meeting': return Colors.teal;
      default: return Colors.deepPurpleAccent; 
    }
  }

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
                child: Form(
                  key: _formKey,
                  autovalidateMode: autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// App Bar
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),

                          const Spacer(),

                          const Text(
                            'Add New Task',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          'Add the task details to stay organized',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                      ),

                      const SizedBox(height: 35),

                      TaskInputCard(
                        title: "Task Title",
                        hint: "e.g. Design Login Screen",
                        icon: Icons.assignment_outlined,
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Task title is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TaskInputCard(
                        controller: descriptionController,
                        title: "Description",
                        hint: "Write task details...",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        optional: " (Optional)",
                        validator: null,
                      ),

                      const SizedBox(height: 18),

                      TaskInputCard(
                        controller: categoryController,
                        title: "Category",
                        hint: "e.g. Development",
                        icon: Icons.sell_outlined,
                        optional: " (Optional)",
                        validator: null,
                      ),

                      const SizedBox(height: 18),

                      StatusSection(
                        selectedStatus: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              autoValidate = true;
                            });

                            if (_formKey.currentState!.validate()) {
                              final newTask = TaskModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(), 
                                title: titleController.text.trim(),
                                category: categoryController.text.trim().isEmpty 
                                    ? "General" 
                                    : categoryController.text.trim(),
                                categoryColor: _getCategoryColor(categoryController.text),
                                time: "Just Now", 
                                status: _getTaskStatusEnum(selectedStatus),
                              );

                              await DatabaseService.addTask(newTask);

                              titleController.clear();
                              descriptionController.clear();
                              categoryController.clear();

                              setState(() {

                                selectedStatus = "Pending";
                                autoValidate = false;
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Task Added Successfully"),
                                  ),
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Task Added Successfully"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6C63FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "+  Add Task",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

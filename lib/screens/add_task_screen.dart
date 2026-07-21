import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/status_section.dart';
import '../widgets/task_input_card.dart';

/// Screen used for BOTH creating a new task and editing an existing one.
///
/// Pass an [task] to enter "edit" mode; omit it for "create" mode.
/// Navigated to via [AppRoutes.addTask] and [AppRoutes.editTask].
class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();

  String selectedStatus = 'Pending';
  bool autoValidate = false;
  bool _saving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.task!;
      titleController.text = t.title;
      descriptionController.text = t.description;
      categoryController.text = t.category == 'General' ? '' : t.category;
      selectedStatus = t.status.label;
    }
  }

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
      default:
        return TaskStatus.pending;
    }
  }

  Color _getCategoryColor(String category) {
    if (category.trim().isEmpty) return Colors.grey;
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.purple;
      case 'development':
        return Colors.blue;
      case 'backend':
        return Colors.orange;
      case 'meeting':
        return Colors.teal;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  Future<void> _submit() async {
    setState(() => autoValidate = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final provider = context.read<TaskProvider>();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final category = categoryController.text.trim();
    final status = _getTaskStatusEnum(selectedStatus);
    final color = _getCategoryColor(category);

    try {
      if (isEditing) {
        final updated = widget.task!.copyWith(
          title: title,
          description: description,
          category: category.isEmpty ? 'General' : category,
          categoryColor: color,
          status: status,
          time: DateFormat('h:mm a').format(DateTime.now()),
        );
        await provider.updateTask(updated);
      } else {
        await provider.addTask(
          title: title,
          description: description,
          category: category,
          categoryColor: color,
          status: status,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Task Updated Successfully'
              : 'Task Added Successfully'),
        ),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _titleInput() => TaskInputCard(
        title: 'Task Title',
        hint: 'e.g. Design Login Screen',
        icon: Icons.assignment_outlined,
        controller: titleController,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Task title is required' : null,
      );

  Widget _descriptionInput() => TaskInputCard(
        controller: descriptionController,
        title: 'Description',
        hint: 'Write task details...',
        icon: Icons.description_outlined,
        maxLines: 4,
        optional: ' (Optional)',
        validator: null,
      );

  Widget _categoryInput() => TaskInputCard(
        controller: categoryController,
        title: 'Category',
        hint: 'e.g. Development',
        icon: Icons.sell_outlined,
        optional: ' (Optional)',
        validator: null,
      );

  Widget _statusSection() => StatusSection(
        selectedStatus: selectedStatus,
        onChanged: (v) => setState(() => selectedStatus = v),
      );

  Widget _submitBtn() => SizedBox(
        width: double.infinity,
        height: 58,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _saving
              ? Container(
                  key: const ValueKey('loading'),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                  ),
                )
              : Container(
                  key: const ValueKey('idle'),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _submit,
                      child: Center(
                        child: Text(
                          isEditing ? 'Update Task' : '+  Add Task',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final padH = Responsive.screenPadding(context);
    final wide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            /// Gradient header
            Container(
              decoration: const BoxDecoration(gradient: AppGradients.header),
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: 16),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Task' : 'New Task',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'Update the task details below'
                              : 'Add the task details to stay organized',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Body
            Expanded(
              child: CenteredConstrained(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(padH, 24, padH, 32),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: autoValidate
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: wide ? _twoColumn() : _singleColumn(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleInput(),
        const SizedBox(height: 16),
        _descriptionInput(),
        const SizedBox(height: 16),
        _categoryInput(),
        const SizedBox(height: 18),
        _statusSection(),
        const SizedBox(height: 28),
        _submitBtn(),
      ],
    );
  }

  Widget _twoColumn() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleInput(),
              const SizedBox(height: 16),
              _descriptionInput(),
              const SizedBox(height: 16),
              _categoryInput(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusSection(),
              const SizedBox(height: 28),
              _submitBtn(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small circular icon button used in the gradient header.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

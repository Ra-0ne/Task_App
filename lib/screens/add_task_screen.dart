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

class _AddTaskScreenState extends State<AddTaskScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final titleFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final categoryFocus = FocusNode();

  String selectedStatus = 'Pending';
  bool autoValidate = false;
  bool _saving = false;

  late final AnimationController _stagger;
  late final List<Animation<double>> _fieldAnims;

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

    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fieldAnims = List.generate(6, (i) {
      final start = i * 0.07;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _stagger,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _stagger.forward());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    titleFocus.dispose();
    descriptionFocus.dispose();
    categoryFocus.dispose();
    _stagger.dispose();
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

    FocusScope.of(context).unfocus();
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
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(isEditing
                  ? 'Task Updated Successfully'
                  : 'Task Added Successfully'),
            ],
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _staggered(int index, Widget child) {
    return FadeTransition(
      opacity: _fieldAnims[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(_fieldAnims[index]),
        child: child,
      ),
    );
  }

  /// Section label with a small accent bar.
  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );

  Widget _titleInput() => TaskInputCard(
        title: 'Task Title',
        hint: 'e.g. Design Login Screen',
        icon: Icons.assignment_outlined,
        controller: titleController,
        focusNode: titleFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => descriptionFocus.requestFocus(),
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
        focusNode: descriptionFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => categoryFocus.requestFocus(),
        validator: null,
      );

  /// Category input with a live color indicator dot.
  Widget _categoryInput() {
    return AnimatedBuilder(
      animation: categoryController,
      builder: (context, _) {
        final color = _getCategoryColor(categoryController.text);
        return TaskInputCard(
          controller: categoryController,
          title: 'Category',
          hint: 'e.g. Development',
          icon: Icons.sell_outlined,
          optional: ' (Optional)',
          focusNode: categoryFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          validator: null,
          trailing: categoryController.text.trim().isNotEmpty
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withValues(alpha: .3), width: 3),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _statusSection() => StatusSection(
        selectedStatus: selectedStatus,
        onChanged: (v) => setState(() => selectedStatus = v),
      );

  Widget _submitBtn() => SizedBox(
        width: double.infinity,
        height: 56,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isEditing ? Icons.check_rounded : Icons.add,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Update Task' : 'Add Task',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            /// Gradient header with rounded bottom corners
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.header,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(padH, 12, padH, 24),
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
                          isEditing ? 'Edit Task' : 'Create New Task',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Update the task details below'
                              : 'Fill in the details below to add a new task',
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

            /// Body — scrollable form
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: CenteredConstrained(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(padH, 24, padH, 16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
            ),

            /// Sticky submit bar — always visible above keyboard
            Container(
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(padH, 12, padH, 16),
              child: CenteredConstrained(child: _submitBtn()),
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
        _staggered(0, _sectionLabel('Task Details')),
        _staggered(1, _titleInput()),
        const SizedBox(height: 16),
        _staggered(1, _descriptionInput()),
        const SizedBox(height: 24),

        _staggered(2, _sectionLabel('Organization')),
        _staggered(3, _categoryInput()),
        const SizedBox(height: 24),

        _staggered(4, _sectionLabel('Status')),
        _staggered(5, _statusSection()),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _twoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staggered(0, _sectionLabel('Task Details')),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _staggered(1, _titleInput()),
                  const SizedBox(height: 16),
                  _staggered(1, _descriptionInput()),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _staggered(2, _sectionLabel('Organization')),
                  _staggered(3, _categoryInput()),
                  const SizedBox(height: 20),
                  _staggered(4, _sectionLabel('Status')),
                  _staggered(5, _statusSection()),
                ],
              ),
            ),
          ],
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

import 'package:flutter/material.dart';
import 'package:task_app/utils/app_colors.dart';

class TaskInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String optional;

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? trailing;

  const TaskInputCard({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.maxLines = 1,
    this.optional = '',
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = maxLines > 1;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffF2EEFF), Color(0xffE5DEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(optional,
                        style: const TextStyle(color: textSecondary)),
                    const Spacer(),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  validator: validator,
                  maxLines: maxLines,
                  focusNode: focusNode,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  autovalidateMode: AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFC),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: isMulti ? 14 : 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xff6C63FF), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.8),
                    ),
                    errorStyle:
                        const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

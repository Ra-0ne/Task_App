import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search_rounded, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              onChanged: (v) =>
                  context.read<TaskProvider>().setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
            ),
          ),
          Selector<TaskProvider, bool>(
            selector: (_, p) => p.searchQuery.isNotEmpty,
            builder: (_, hasText, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: hasText
                  ? IconButton(
                      key: const ValueKey('clear'),
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        context.read<TaskProvider>().setSearchQuery('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

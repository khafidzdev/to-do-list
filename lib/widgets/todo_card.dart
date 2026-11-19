import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoCard extends StatelessWidget {
  final TodoItem todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFEF4444); // Red 500
      case 'sedang':
        return const Color(0xFFF59E0B); // Amber 500
      case 'rendah':
        return const Color(0xFF10B981); // Emerald 500
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getPriorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFFEF2F2);
      case 'sedang':
        return const Color(0xFFFFFBEB);
      case 'rendah':
        return const Color(0xFFECFDF5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return const Color(0xFF4F46E5);
      case 'pekerjaan':
        return const Color(0xFF0284C7);
      case 'tugas':
        return const Color(0xFF7C3AED);
      case 'pribadi':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getCategoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return const Color(0xFFEEF2FF);
      case 'pekerjaan':
        return const Color(0xFFF0F9FF);
      case 'tugas':
        return const Color(0xFFF5F3FF);
      case 'pribadi':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(todo.priority);
    final priorityBg = _getPriorityBg(todo.priority);
    final categoryColor = _getCategoryColor(todo.category);
    final categoryBg = _getCategoryBg(todo.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: todo.isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: todo.isCompleted
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: todo.isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Circular Checkbox
                GestureDetector(
                  onTap: () => onToggle(!todo.isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 2.0, right: 12.0),
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: todo.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.white,
                      border: Border.all(
                        color: todo.isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                        width: 2.0,
                      ),
                      boxShadow: todo.isCompleted
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 6.0,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: todo.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16.0,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: todo.isCompleted
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF94A3B8),
                        ),
                      ),

                      if (todo.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: todo.isCompleted
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF64748B),
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10.0),

                      // Tags & Metadata
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Priority Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: priorityBg,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: priorityColor,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  todo.priority,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: priorityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Category Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9.0, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: categoryBg,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              todo.category,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),

                          // Due Date
                          if (todo.dueDate != null && todo.dueDate!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 3.5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 13.0,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    todo.dueDate!,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Popup Options Menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 18.0,
                    color: Color(0xFF94A3B8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4F46E5)),
                          SizedBox(width: 10),
                          Text("Edit", style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 10),
                          Text("Hapus", style: TextStyle(fontSize: 13.5, color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

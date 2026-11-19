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
        return Colors.red.shade600;
      case 'sedang':
        return Colors.orange.shade700;
      case 'rendah':
        return Colors.green.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return Colors.indigo;
      case 'tugas':
        return Colors.deepPurple;
      case 'pekerjaan':
        return Colors.blue.shade700;
      case 'pribadi':
        return Colors.teal.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(todo.priority);
    final categoryColor = _getCategoryColor(todo.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      elevation: todo.isCompleted ? 0.5 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(
          color: todo.isCompleted
              ? Colors.grey.shade300
              : priorityColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      color: todo.isCompleted ? Colors.grey.shade50 : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 10.0, 12.0, 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox untuk status selesai/belum
              Transform.scale(
                scale: 1.15,
                child: Checkbox(
                  value: todo.isCompleted,
                  activeColor: Colors.teal.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  onChanged: onToggle,
                ),
              ),
              const SizedBox(width: 4.0),
              // Detail Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Tugas
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isCompleted
                            ? Colors.grey.shade600
                            : Colors.black87,
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
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    // Badges Prioritas, Kategori, dan Due Date
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Chip Prioritas
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: priorityColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                size: 12.0,
                                color: priorityColor,
                              ),
                              const SizedBox(width: 3.0),
                              Text(
                                todo.priority,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chip Kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            todo.category,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        // Due Date
                        if (todo.dueDate != null && todo.dueDate!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11.5,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  todo.dueDate!,
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.grey.shade700,
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
              // Menu Popup Titik Tiga (Edit, Hapus)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade600,
                  size: 20.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18.0, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18.0, color: Colors.red),
                        SizedBox(width: 8.0),
                        Text("Hapus"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

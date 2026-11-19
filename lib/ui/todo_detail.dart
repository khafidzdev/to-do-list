import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/todo_item.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/success_dialog.dart';
import 'todo_form.dart';

class TodoDetailPage extends StatefulWidget {
  final TodoItem todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late TodoItem _currentTodo;

  @override
  void initState() {
    super.initState();
    _currentTodo = widget.todo;
  }

  Future<void> _refreshTodo() async {
    if (_currentTodo.id == null) return;
    final updated = await DbHelper().getTodoById(_currentTodo.id!);
    if (updated != null && mounted) {
      setState(() {
        _currentTodo = updated;
      });
    }
  }

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

  Future<void> _toggleStatus() async {
    if (_currentTodo.id == null) return;
    final newStatus = !_currentTodo.isCompleted;
    await DbHelper().toggleTodoStatus(_currentTodo.id!, newStatus);
    if (!mounted) return;
    setState(() {
      _currentTodo = _currentTodo.copyWith(isCompleted: newStatus);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? "Tugas ditandai selesai"
              : "Tugas ditandai belum selesai",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: "Hapus Catatan / Tugas",
        description:
            "Apakah Anda yakin ingin menghapus '${_currentTodo.title}' dari penyimpanan lokal?",
        confirmText: "Hapus",
        confirmColor: Colors.red,
      ),
    );

    if (confirmed == true && mounted) {
      if (_currentTodo.id != null) {
        await DbHelper().deleteTodo(_currentTodo.id!);
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => SuccessDialog(
            description: "Catatan tugas berhasil dihapus!",
            okClick: () {
              Navigator.of(ctx).pop();
            },
          ),
        );
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TodoFormPage(todo: _currentTodo),
      ),
    );

    if (result == true) {
      await _refreshTodo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(_currentTodo.priority);
    final categoryColor = _getCategoryColor(_currentTodo.category);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Detail Catatan / Tugas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Edit Tugas",
              onPressed: _navigateToEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: "Hapus Tugas",
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Status Utama
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _currentTodo.isCompleted
                      ? Colors.teal.shade50
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _currentTodo.isCompleted
                        ? Colors.teal.shade200
                        : Colors.amber.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentTodo.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      size: 36.0,
                      color: _currentTodo.isCompleted
                          ? Colors.teal.shade700
                          : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentTodo.isCompleted
                                ? "STATUS: SELESAI"
                                : "STATUS: BELUM SELESAI",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: _currentTodo.isCompleted
                                  ? Colors.teal.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _currentTodo.isCompleted
                                ? "Tugas ini telah diselesaikan."
                                : "Tugas ini masih harus dikerjakan.",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentTodo.isCompleted
                            ? Colors.grey.shade200
                            : Colors.teal,
                        foregroundColor: _currentTodo.isCompleted
                            ? Colors.black87
                            : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      onPressed: _toggleStatus,
                      child: Text(
                        _currentTodo.isCompleted ? "Batal Selesai" : "Selesai",
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Judul Tugas
              Text(
                _currentTodo.title,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  decoration: _currentTodo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),

              const SizedBox(height: 12.0),

              // Baris Kategori & Prioritas
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: priorityColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, size: 14.0, color: priorityColor),
                        const SizedBox(width: 4.0),
                        Text(
                          "Prioritas: ${_currentTodo.priority}",
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 14.0, color: categoryColor),
                        const SizedBox(width: 4.0),
                        Text(
                          _currentTodo.category,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20.0),
              const Divider(),
              const SizedBox(height: 12.0),

              // Bagian Rincian Catatan / Deskripsi
              const Text(
                "Rincian / Catatan:",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  _currentTodo.description.trim().isNotEmpty
                      ? _currentTodo.description
                      : "(Tidak ada catatan tambahan)",
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: _currentTodo.description.trim().isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade500,
                    fontStyle: _currentTodo.description.trim().isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Bagian Informasi Waktu (Tenggat Waktu & Dibuat Pada)
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18.0, color: Colors.indigo),
                        const SizedBox(width: 10.0),
                        const Text(
                          "Tenggat Waktu: ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Text(
                            _currentTodo.dueDate != null &&
                                    _currentTodo.dueDate!.isNotEmpty
                                ? _currentTodo.dueDate!
                                : "Tidak ada deadline",
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20.0),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18.0, color: Colors.blueGrey),
                        const SizedBox(width: 10.0),
                        const Text(
                          "Dibuat Pada: ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Text(
                            _currentTodo.createdAt.length >= 16
                                ? _currentTodo.createdAt.substring(0, 16).replaceAll('T', ' ')
                                : _currentTodo.createdAt,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32.0),

              // Tombol Aksi Bawah
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        side: const BorderSide(color: Colors.redAccent),
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("HAPUS"),
                      onPressed: _confirmDelete,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text("EDIT TUGAS"),
                      onPressed: _navigateToEdit,
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

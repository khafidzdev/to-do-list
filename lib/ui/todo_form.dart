import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../models/todo_item.dart';
import '../widgets/success_dialog.dart';
import '../widgets/warning_dialog.dart';

class TodoFormPage extends StatefulWidget {
  final TodoItem? todo;

  const TodoFormPage({super.key, this.todo});

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController sesuai fokus pembelajaran materi
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String _selectedCategory = 'Kuliah';
  String _selectedPriority = 'Sedang';
  DateTime? _selectedDueDate;
  bool _isCompleted = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Kuliah',
    'Tugas',
    'Pekerjaan',
    'Pribadi',
    'Lainnya',
  ];

  final List<String> _priorities = [
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  bool get _isEditMode => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.todo!.title);
      _descriptionController = TextEditingController(text: widget.todo!.description);
      _selectedCategory = _categories.contains(widget.todo!.category)
          ? widget.todo!.category
          : 'Kuliah';
      _selectedPriority = _priorities.contains(widget.todo!.priority)
          ? widget.todo!.priority
          : 'Sedang';
      if (widget.todo!.dueDate != null && widget.todo!.dueDate!.isNotEmpty) {
        try {
          _selectedDueDate = DateTime.parse(widget.todo!.dueDate!);
        } catch (_) {
          _selectedDueDate = null;
        }
      }
      _isCompleted = widget.todo!.isCompleted;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _saveTodo() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const WarningDialog(
          description: "Harap periksa form. Judul tugas wajib diisi dengan benar!",
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dueDateString = _selectedDueDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
          : null;

      if (_isEditMode) {
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: dueDateString,
          isCompleted: _isCompleted,
        );

        await DbHelper().updateTodo(updatedTodo);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            description: "Perubahan tugas berhasil diperbarui!",
            okClick: () {
              Navigator.of(context).pop(true);
            },
          ),
        );
      } else {
        final newTodo = TodoItem(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: dueDateString,
          isCompleted: false,
        );

        await DbHelper().insertTodo(newTodo);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SuccessDialog(
            description: "Tugas baru berhasil ditambahkan!",
            okClick: () {
              Navigator.of(context).pop(true);
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => WarningDialog(
          description: "Terjadi kesalahan saat menyimpan data: $e",
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Catatan / Tugas" : "Tambah Catatan / Tugas",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Informasi Tugas"),
                    const SizedBox(height: 12.0),
                    _titleTextField(),
                    const SizedBox(height: 16.0),
                    _descriptionTextField(),
                    const SizedBox(height: 20.0),
                    _sectionHeader("Kategori & Prioritas"),
                    const SizedBox(height: 12.0),
                    _categoryDropdown(),
                    const SizedBox(height: 16.0),
                    _prioritySelector(),
                    const SizedBox(height: 20.0),
                    _sectionHeader("Tenggat Waktu (Deadline)"),
                    const SizedBox(height: 12.0),
                    _datePickerTile(),
                    if (_isEditMode) ...[
                      const SizedBox(height: 20.0),
                      _sectionHeader("Status Penyelesaian"),
                      const SizedBox(height: 8.0),
                      _statusSwitch(),
                    ],
                    const SizedBox(height: 32.0),
                    _saveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _titleTextField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: "Judul Catatan / Tugas *",
        hintText: "Contoh: Kerjakan Bab 3 Tugas Akhir",
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Judul catatan / tugas tidak boleh kosong!";
        }
        if (value.trim().length < 3) {
          return "Judul minimal 3 karakter";
        }
        return null;
      },
    );
  }

  Widget _descriptionTextField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: "Deskripsi / Catatan Tambahan (Opsional)",
        hintText: "Tuliskan rincian tugas atau langkah pengerjaan...",
        prefixIcon: const Icon(Icons.notes_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey.shade50,
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Kategori Tugas",
        prefixIcon: const Icon(Icons.category_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedCategory = val;
          });
        }
      },
    );
  }

  Widget _prioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tingkat Prioritas:",
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: _priorities.map((priority) {
            final isSelected = _selectedPriority == priority;
            Color chipColor;
            if (priority == 'Tinggi') {
              chipColor = Colors.red;
            } else if (priority == 'Sedang') {
              chipColor = Colors.orange;
            } else {
              chipColor = Colors.green;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      priority,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: chipColor,
                  backgroundColor: chipColor.withValues(alpha: 0.1),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDisplayDate(DateTime? date) {
    if (date == null) return "Belum ditentukan";
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').format(date);
      } catch (_) {
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
    }
  }

  Widget _datePickerTile() {
    final dateDisplay = _formatDisplayDate(_selectedDueDate);

    return InkWell(
      onTap: _pickDueDate,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: Colors.indigo),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tenggat Waktu",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    dateDisplay,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _pickDueDate,
              child: const Text("Pilih Tanggal"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusSwitch() {
    return SwitchListTile(
      title: const Text(
        "Tandai Telah Selesai",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _isCompleted ? "Tugas ini sudah selesai" : "Tugas ini masih berjalan",
      ),
      value: _isCompleted,
      activeThumbColor: Colors.teal,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        setState(() {
          _isCompleted = val;
        });
      },
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.save_rounded),
        label: Text(
          _isEditMode ? "SIMPAN PERUBAHAN" : "SIMPAN TUGAS",
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        onPressed: _saveTodo,
      ),
    );
  }
}

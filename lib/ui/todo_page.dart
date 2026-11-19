import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/todo_item.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/todo_card.dart';
import 'todo_detail.dart';
import 'todo_form.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _searchController = TextEditingController();

  List<TodoItem> _todos = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Belum Selesai', 'Selesai'
  String _selectedCategoryFilter = 'Semua';

  Map<String, int> _stats = {
    'total': 0,
    'completed': 0,
    'pending': 0,
  };

  final List<String> _statusOptions = [
    'Semua',
    'Belum Selesai',
    'Selesai',
  ];

  final List<String> _categoryOptions = [
    'Semua',
    'Kuliah',
    'Tugas',
    'Pekerjaan',
    'Pribadi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await DbHelper().getTodos(
        searchQuery: _searchController.text.trim(),
        statusFilter: _selectedStatusFilter,
        categoryFilter: _selectedCategoryFilter,
      );
      final stats = await DbHelper().getStats();

      if (mounted) {
        setState(() {
          _todos = todos;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTodo(TodoItem todo, bool? value) async {
    if (todo.id == null) return;
    final newStatus = value ?? !todo.isCompleted;
    await DbHelper().toggleTodoStatus(todo.id!, newStatus);
    await _loadData();
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TodoFormPage()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToDetail(TodoItem todo) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TodoDetailPage(todo: todo)),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEdit(TodoItem todo) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TodoFormPage(todo: todo)),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _deleteTodo(TodoItem todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: "Hapus Catatan / Tugas",
        description:
            "Apakah Anda yakin ingin menghapus '${todo.title}' dari penyimpanan lokal?",
        confirmText: "Hapus",
        confirmColor: Colors.red,
      ),
    );

    if (confirmed == true && mounted) {
      if (todo.id != null) {
        await DbHelper().deleteTodo(todo.id!);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => const SuccessDialog(
            description: "Catatan tugas berhasil dihapus!",
          ),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Notes & To-Do List",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            Text(
              "Penyimpanan Lokal SQLite (UTS INF3022)",
              style: TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Muat Ulang Data",
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Ringkasan Statistik Tugas
          _buildStatsSummary(),

          // 2. Bar Pencarian berdasarkan Judul (Search Bar)
          _buildSearchBar(),

          // 3. Filter Status & Kategori
          _buildFilterChips(),

          // 4. Daftar Tugas (ListView / Empty State)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80.0, top: 4.0),
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            return TodoCard(
                              todo: todo,
                              onToggle: (val) => _toggleTodo(todo, val),
                              onTap: () => _navigateToDetail(todo),
                              onEdit: () => _navigateToEdit(todo),
                              onDelete: () => _deleteTodo(todo),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text(
          "Tambah Tugas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget Ringkasan Statistik
  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Tugas", "${_stats['total'] ?? 0}", Icons.list_alt_rounded),
          Container(height: 28, width: 1, color: Colors.white24),
          _buildStatItem("Tertunda", "${_stats['pending'] ?? 0}", Icons.pending_actions_rounded),
          Container(height: 28, width: 1, color: Colors.white24),
          _buildStatItem("Selesai", "${_stats['completed'] ?? 0}", Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14.0),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 6.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari catatan berdasarkan judul...",
          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search_rounded, size: 22.0),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18.0),
                  onPressed: () {
                    _searchController.clear();
                    _loadData();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          _loadData();
        },
      ),
    );
  }

  // Widget Filter Chips (Status & Kategori)
  Widget _buildFilterChips() {
    return Column(
      children: [
        // Filter Status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
          child: Row(
            children: [
              ..._statusOptions.map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey.shade200,
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    onSelected: (val) {
                      setState(() {
                        _selectedStatusFilter = status;
                      });
                      _loadData();
                    },
                  ),
                );
              }),
              const SizedBox(width: 4.0),
              // Dropdown Kategori Cepat
              Container(
                height: 32.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryFilter,
                    icon: const Icon(Icons.arrow_drop_down, size: 18.0),
                    style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategoryFilter = val;
                        });
                        _loadData();
                      }
                    },
                    items: _categoryOptions.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat == 'Semua' ? 'Kategori: Semua' : cat),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tampilan ketika data kosong
  Widget _buildEmptyState() {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.checklist_rtl_rounded,
              size: 72.0,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14.0),
            Text(
              isSearching
                  ? "Tidak ada catatan ditemukan"
                  : "Belum Ada Catatan / Tugas",
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              isSearching
                  ? "Coba gunakan kata kunci pencarian yang lain."
                  : "Mulai buat catatan tugas pertama Anda dengan menekan tombol '+' di bawah.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey.shade500,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 14.0),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  _loadData();
                },
                child: const Text("Reset Pencarian"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

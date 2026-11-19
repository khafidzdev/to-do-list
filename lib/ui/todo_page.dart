import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.apps_rounded},
    {'name': 'Kuliah', 'icon': Icons.school_rounded},
    {'name': 'Tugas', 'icon': Icons.assignment_rounded},
    {'name': 'Pekerjaan', 'icon': Icons.work_rounded},
    {'name': 'Pribadi', 'icon': Icons.person_rounded},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded},
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
        title: "Hapus Tugas",
        description: "Apakah Anda yakin ingin menghapus '${todo.title}'?",
        confirmText: "Hapus",
        confirmColor: const Color(0xFFEF4444),
      ),
    );

    if (confirmed == true && mounted) {
      if (todo.id != null) {
        await DbHelper().deleteTodo(todo.id!);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => const SuccessDialog(
            description: "Tugas berhasil dihapus!",
          ),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Modern Header (App Bar)
            _buildModernHeader(),

            // 2. Productivity Hero Banner
            _buildHeroBanner(),

            // 3. Search Bar
            _buildSearchBar(),

            // 4. Filter Chips (Status & Kategori)
            _buildFilters(),

            // 5. Daftar Tugas (ListView / Empty State)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    )
                  : _todos.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF4F46E5),
                          onRefresh: _loadData,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 84.0, top: 4.0),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        elevation: 3,
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Tugas Baru",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
      ),
    );
  }

  // Modern Header
  Widget _buildModernHeader() {
    final now = DateTime.now();
    final dateFormatted = DateFormat('EEEE, d MMM', 'id_ID').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 14.0, 16.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "FlowDo",
                        style: TextStyle(
                          fontSize: 21.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        width: 6.0,
                        height: 6.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: _loadData,
            tooltip: "Muat Ulang",
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            icon: const Icon(
              Icons.sync_rounded,
              color: Color(0xFF475569),
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  // Hero Progress Card
  Widget _buildHeroBanner() {
    final total = _stats['total'] ?? 0;
    final completed = _stats['completed'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final percentage = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3730A3), // Indigo 800
            Color(0xFF4F46E5), // Indigo 600
            Color(0xFF7C3AED), // Violet 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progres Hari Ini",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  "$percentage% Selesai",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: LinearProgressIndicator(
              value: total > 0 ? (completed / total) : 0.0,
              minHeight: 7.0,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
            ),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              _buildMiniStatBadge("Total", "$total", Icons.assignment_outlined),
              const SizedBox(width: 8.0),
              _buildMiniStatBadge("Tertunda", "$pending", Icons.hourglass_top_rounded),
              const SizedBox(width: 8.0),
              _buildMiniStatBadge("Selesai", "$completed", Icons.check_circle_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBadge(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.0, color: Colors.white70),
            const SizedBox(width: 5.0),
            Text(
              "$value $label",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => _loadData(),
          style: const TextStyle(fontSize: 14.0),
          decoration: InputDecoration(
            hintText: "Cari tugas atau catatan...",
            hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20.0,
              color: Color(0xFF64748B),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18.0),
                    onPressed: () {
                      _searchController.clear();
                      _loadData();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
        ),
      ),
    );
  }

  // Filters (Status Tabs & Category Pills)
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
      child: Column(
        children: [
          // Status Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = status;
                      });
                      _loadData();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8.0),

          // Category Chips (Horizontal Scrollable)
          SizedBox(
            height: 34.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryFilter == cat['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = cat['name'] as String;
                    });
                    _loadData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 14.0,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Modern Empty State
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 38.0,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Semua Tugas Tuntas!",
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              "Tidak ada tugas yang sesuai filter.\nWaktunya bersantai atau buat tugas baru.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18.0),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Buat Tugas Baru"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

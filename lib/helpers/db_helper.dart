import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/todo_item.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  static const String tableName = 'todos';
  static const String dbName = 'todo_app.db';
  static const int dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    // Inisialisasi FFI untuk desktop Linux / Windows / macOS agar kompatibel di berbagai platform
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        due_date TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Masukkan data awal (dummy/sample data) agar aplikasi langsung terisi saat pertama dibuka
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    final sampleItems = [
      {
        'title': 'Mengerjakan UTS Pemrograman Mobile Lanjut',
        'description': 'Menyelesaikan aplikasi Quick Notes & To-Do List dengan Flutter dan SQLite lokal.',
        'category': 'Kuliah',
        'priority': 'Tinggi',
        'due_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 2).toString().padLeft(2, '0')}',
        'is_completed': 0,
        'created_at': now.toIso8601String(),
      },
      {
        'title': 'Membaca Modul Pemrograman Mobile Lanjut',
        'description': 'Mempelajari arsitektur Flutter, Form validation, TextEditingController, dan SQLite.',
        'category': 'Kuliah',
        'priority': 'Sedang',
        'due_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'is_completed': 1,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'title': 'Beli Kebutuhan Mingguan',
        'description': 'Membeli buah, sayuran, dan susu di supermarket.',
        'category': 'Pribadi',
        'priority': 'Rendah',
        'due_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 4).toString().padLeft(2, '0')}',
        'is_completed': 0,
        'created_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'title': 'Review Pull Request Tim',
        'description': 'Periksa kode clean architecture dan struktur widget rekan satu kelompok.',
        'category': 'Tugas',
        'priority': 'Sedang',
        'due_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}',
        'is_completed': 0,
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    for (final item in sampleItems) {
      await db.insert(tableName, item);
    }
  }

  // CREATE: Tambah tugas baru
  Future<int> insertTodo(TodoItem todo) async {
    final db = await database;
    return await db.insert(tableName, todo.toMap());
  }

  // READ: Ambil semua tugas dengan filter pencarian, status, dan kategori
  Future<List<TodoItem>> getTodos({
    String? searchQuery,
    String? statusFilter, // 'Semua', 'Selesai', 'Belum Selesai'
    String? categoryFilter, // 'Semua', 'Kuliah', 'Tugas', 'Pribadi', dll.
  }) async {
    final db = await database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    // Filter pencarian berdasarkan judul (Case-Insensitive)
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('LOWER(title) LIKE ?');
      whereArgs.add('%${searchQuery.trim().toLowerCase()}%');
    }

    // Filter status
    if (statusFilter != null && statusFilter != 'Semua') {
      if (statusFilter == 'Selesai') {
        whereClauses.add('is_completed = 1');
      } else if (statusFilter == 'Belum Selesai') {
        whereClauses.add('is_completed = 0');
      }
    }

    // Filter kategori
    if (categoryFilter != null && categoryFilter != 'Semua') {
      whereClauses.add('category = ?');
      whereArgs.add(categoryFilter);
    }

    String? where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_completed ASC, id DESC',
    );

    return List.generate(maps.length, (i) => TodoItem.fromMap(maps[i]));
  }

  // READ: Ambil satu tugas berdasarkan ID
  Future<TodoItem?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return TodoItem.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE: Perbarui data tugas
  Future<int> updateTodo(TodoItem todo) async {
    final db = await database;
    return await db.update(
      tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // UPDATE: Toggle status selesai / belum selesai
  Future<int> toggleTodoStatus(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      tableName,
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Hapus tugas berdasarkan ID
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil data ringkasan statistik (Total, Selesai, Belum Selesai)
  Future<Map<String, int>> getStats() async {
    final db = await database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName WHERE is_completed = 1');

    int total = Sqflite.firstIntValue(totalResult) ?? 0;
    int completed = Sqflite.firstIntValue(completedResult) ?? 0;
    int pending = total - completed;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }
}

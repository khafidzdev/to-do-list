import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/helpers/db_helper.dart';
import 'package:todo_list/models/todo_item.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DbHelper SQLite CRUD Tests', () {
    test('CRUD Operasi Lengkap di SQLite', () async {
      final dbHelper = DbHelper();

      // 1. CREATE
      final newTodo = TodoItem(
        title: 'Tugas Testing CRUD',
        description: 'Testing operasi insert ke SQLite',
        category: 'Tugas',
        priority: 'Tinggi',
        dueDate: '2026-12-01',
        isCompleted: false,
      );
      final insertedId = await dbHelper.insertTodo(newTodo);
      expect(insertedId, isPositive);

      // 2. READ (Get by ID)
      final fetched = await dbHelper.getTodoById(insertedId);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Tugas Testing CRUD');
      expect(fetched.isCompleted, false);

      // 3. SEARCH (Pencarian berdasarkan judul)
      final searchResults = await dbHelper.getTodos(searchQuery: 'Testing CRUD');
      expect(searchResults.any((t) => t.id == insertedId), isTrue);

      // 4. UPDATE (Perbarui judul & deskripsi)
      final updatedTodo = fetched.copyWith(
        title: 'Tugas Testing CRUD (Updated)',
        priority: 'Sedang',
      );
      await dbHelper.updateTodo(updatedTodo);
      final afterUpdate = await dbHelper.getTodoById(insertedId);
      expect(afterUpdate!.title, 'Tugas Testing CRUD (Updated)');
      expect(afterUpdate.priority, 'Sedang');

      // 5. TOGGLE STATUS (Tandai selesai)
      await dbHelper.toggleTodoStatus(insertedId, true);
      final afterToggle = await dbHelper.getTodoById(insertedId);
      expect(afterToggle!.isCompleted, true);

      // 6. STATS
      final stats = await dbHelper.getStats();
      expect(stats['total']!, greaterThanOrEqualTo(1));
      expect(stats['completed']!, greaterThanOrEqualTo(1));

      // 7. DELETE (Hapus tugas)
      await dbHelper.deleteTodo(insertedId);
      final afterDelete = await dbHelper.getTodoById(insertedId);
      expect(afterDelete, isNull);
    });
  });
}

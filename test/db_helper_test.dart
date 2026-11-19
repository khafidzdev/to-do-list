import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/helpers/db_helper.dart';
import 'package:todo_list/models/todo_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DbHelper dapat menyimpan dan membaca data di desktop/FFI', () async {
    final dbHelper = DbHelper();
    final item = TodoItem(
      title: 'Test SQLite FFI',
      description: 'Uji coba CRUD database di Desktop',
      category: 'Kuliah',
      priority: 'Tinggi',
      dueDate: '2026-11-20',
      isCompleted: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await dbHelper.insertTodo(item);
    expect(id, isPositive);

    final todos = await dbHelper.getTodos();
    expect(todos.any((t) => t.title == 'Test SQLite FFI'), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/todo_item.dart';

void main() {
  group('TodoItem Model Tests', () {
    test('Membuat TodoItem baru dengan nilai default', () {
      final todo = TodoItem(title: 'Belajar Flutter SQLite');

      expect(todo.title, 'Belajar Flutter SQLite');
      expect(todo.description, '');
      expect(todo.category, 'Umum');
      expect(todo.priority, 'Sedang');
      expect(todo.isCompleted, false);
      expect(todo.dueDate, isNull);
      expect(todo.createdAt, isNotEmpty);
    });

    test('Konversi ke Map (toMap) dan dari Map (fromMap)', () {
      final now = DateTime.now().toIso8601String();
      final todo = TodoItem(
        id: 1,
        title: 'UTS Pemrograman Mobile',
        description: 'Mengerjakan aplikasi Quick Notes & To-Do List',
        category: 'Kuliah',
        priority: 'Tinggi',
        dueDate: '2026-11-25',
        isCompleted: true,
        createdAt: now,
      );

      final map = todo.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'UTS Pemrograman Mobile');
      expect(map['description'], 'Mengerjakan aplikasi Quick Notes & To-Do List');
      expect(map['category'], 'Kuliah');
      expect(map['priority'], 'Tinggi');
      expect(map['due_date'], '2026-11-25');
      expect(map['is_completed'], 1);
      expect(map['created_at'], now);

      final fromMapTodo = TodoItem.fromMap(map);
      expect(fromMapTodo.id, 1);
      expect(fromMapTodo.title, 'UTS Pemrograman Mobile');
      expect(fromMapTodo.isCompleted, true);
      expect(fromMapTodo.priority, 'Tinggi');
      expect(fromMapTodo.category, 'Kuliah');
    });

    test('Uji method copyWith', () {
      final todo = TodoItem(
        id: 1,
        title: 'Tugas Awal',
        priority: 'Rendah',
        isCompleted: false,
      );

      final updated = todo.copyWith(
        title: 'Tugas Diperbarui',
        priority: 'Tinggi',
        isCompleted: true,
      );

      expect(updated.id, 1);
      expect(updated.title, 'Tugas Diperbarui');
      expect(updated.priority, 'Tinggi');
      expect(updated.isCompleted, true);
    });
  });
}

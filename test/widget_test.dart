import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/todo_item.dart';
import 'package:todo_list/widgets/confirm_dialog.dart';
import 'package:todo_list/widgets/success_dialog.dart';
import 'package:todo_list/widgets/todo_card.dart';
import 'package:todo_list/widgets/warning_dialog.dart';

void main() {
  testWidgets('Uji Widget TodoCard menampilkan judul dan prioritas', (WidgetTester tester) async {
    final todo = TodoItem(
      id: 1,
      title: 'Tugas Belajar Flutter',
      description: 'Deskripsi tugas belajar Flutter',
      category: 'Kuliah',
      priority: 'Tinggi',
      dueDate: '2026-11-25',
      isCompleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoCard(
            todo: todo,
            onToggle: (_) {},
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tugas Belajar Flutter'), findsOneWidget);
    expect(find.text('Deskripsi tugas belajar Flutter'), findsOneWidget);
    expect(find.text('Kuliah'), findsOneWidget);
    expect(find.text('Tinggi'), findsOneWidget);
  });

  testWidgets('Uji Dialog Sukses dan Peringatan', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuccessDialog(description: 'Berhasil disimpan'),
        ),
      ),
    );
    expect(find.text('BERHASIL'), findsOneWidget);
    expect(find.text('Berhasil disimpan'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WarningDialog(description: 'Peringatan validasi'),
        ),
      ),
    );
    expect(find.text('PERINGATAN'), findsOneWidget);
    expect(find.text('Peringatan validasi'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfirmDialog(
            title: 'Konfirmasi',
            description: 'Yakin hapus?',
            onConfirm: () {},
          ),
        ),
      ),
    );
    expect(find.text('Konfirmasi'), findsOneWidget);
    expect(find.text('Yakin hapus?'), findsOneWidget);
  });
}

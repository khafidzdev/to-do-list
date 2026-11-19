import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Memverifikasi judul AppBar dan Tombol Tambah Tugas', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Beri waktu proses asinkron DB inisialisasi dan refresh frame
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verifikasi keberadaan Judul pada AppBar
    expect(find.text('Quick Notes & To-Do List'), findsOneWidget);
    expect(find.text('Penyimpanan Lokal SQLite (UTS INF3022)'), findsOneWidget);

    // Verifikasi keberadaan FloatingActionButton Tambah Tugas
    expect(find.text('Tambah Tugas'), findsOneWidget);
    expect(find.byIcon(Icons.add_task_rounded), findsOneWidget);

    // Verifikasi keberadaan Search bar
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.text('Cari catatan berdasarkan judul...'), findsOneWidget);
  });
}

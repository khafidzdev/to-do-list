# LAPORAN TUGAS PROJEK UJIAN TENGAH SEMESTER (UTS) GANJIL
## MATA KULIAH: PEMROGRAMAN MOBILE LANJUT (KODE MK: INF3022)
### PROGRAM STUDI S1 TEKNIK INFORMATIKA - FAKULTAS SAINS DAN TEKNOLOGI

---

**Dosen Pengampu:** Eko Budihartono, S.T., M.Kom.  
**Tahun Akademik:** 2026/2027  
**Studi Kasus Dipilih:** **Kasus 2: Quick Notes & To-Do List (Penyimpanan Lokal)**  

---

### IDENTITAS MAHASISWA / ANGGOTA KELOMPOK:
1. **Nama Mahasiswa 1:** [Isi Nama Anda] — **NIM:** [Isi NIM]
2. **Nama Mahasiswa 2:** [Isi Nama Anggota 2 (jika ada)] — **NIM:** [Isi NIM]
3. **Nama Mahasiswa 3:** [Isi Nama Anggota 3 (jika ada)] — **NIM:** [Isi NIM]
**Kelas:** [Kelas A / RM]

---

### TAUTAN PENGUMPULAN PROJEK:
- **Tautan Repositori GitHub:** `https://github.com/username/to-do-list` *(Ganti dengan link repositori Anda)*
- **Tautan Video Pengujian / Demo Aplikasi:** `https://youtu.be/xxxxxx` *(Ganti dengan link YouTube / Google Drive Anda)*

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang
Dalam aktivitas sehari-hari, mahasiswa dan masyarakat umum membutuhkan alat bantu yang cepat, praktis, dan andal untuk mencatat agenda, tugas kuliah, maupun pekerjaan harian. Kehilangan data catatan akibat aplikasi tertutup atau tidak adanya koneksi internet sering menjadi kendala utama. 

Oleh karena itu, dikembangkan aplikasi **Quick Notes & To-Do List** berbasis framework Flutter (bahasa Dart) dengan arsitektur penyimpanan lokal persisten menggunakan basis data relasional **SQLite (`sqflite`)**. Aplikasi ini dirancang agar dapat berjalan secara mandiri tanpa memerlukan internet (*offline-first*), cepat, serta memiliki antarmuka yang intuitif dan responsif pada berbagai ukuran layar ponsel Android (minimal Android 8.0 Oreo).

### 1.2 Tujuan Pembuatan Aplikasi
1. Memenuhi tugas Ujian Tengah Semester (UTS) mata kuliah Pemrograman Mobile Lanjut.
2. Mengimplementasikan operasi lengkap CRUD (*Create, Read, Update, Delete*) pada data catatan dan tugas.
3. Mengintegrasikan penyimpanan lokal permanen menggunakan SQLite agar data tidak terhapus saat aplikasi dimatikan.
4. Menerapkan fitur pencarian judul real-time (*case-insensitive*) dengan `TextEditingController`.
5. Menerapkan *clean code* dengan arsitektur modular yang memisahkan antara layer Model, Helper/Database, UI/Page, dan Widget Dialog sesuai modul praktikum perkuliahan.

---

## BAB II: PERANCANGAN SISTEM & BASIS DATA

### 2.1 Arsitektur Aplikasi
Aplikasi mengadopsi pola arsitektur berlapis (*layered architecture*) yang terdiri dari:
- **Model Layer (`models/todo_item.dart`):** Merepresentasikan entitas data tugas beserta method serialisasi (`toMap`, `fromMap`, `toJson`, `fromJson`, `copyWith`).
- **Database & Helper Layer (`helpers/db_helper.dart`):** Pola desain *Singleton* untuk mengelola koneksi database SQLite, pembuatan tabel, penyisipan data awal (*seeding*), serta fungsi transaksi CRUD dan filter SQL.
- **UI / Presentation Layer (`ui/`):**
  - `todo_page.dart`: Halaman utama yang memuat ringkasan statistik, pencarian judul, filter status & kategori, serta daftar kartu tugas.
  - `todo_form.dart`: Formulir penambahan dan pengubahan tugas dengan validasi form (`GlobalKey<FormState>`).
  - `todo_detail.dart`: Halaman detail informasi tugas lengkap dengan kontrol ubah status, edit, dan hapus.
- **Custom Widget Layer (`widgets/`):**
  - `todo_card.dart`: Komponen kartu daftar tugas dengan checklist interaktif, badge warna prioritas, tag kategori, dan tanggal tenggat waktu.
  - `success_dialog.dart`, `warning_dialog.dart`, dan `confirm_dialog.dart`: Komponen dialog sesuai standar modul praktikum perkuliahan.

### 2.2 Perancangan Skema Database SQLite
Nama berkas database lokal: `todo_app.db`  
Nama tabel: `todos`

| Nama Kolom | Tipe Data SQLite | Keterangan |
|---|---|---|
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | ID unik untuk setiap catatan / tugas |
| `title` | `TEXT NOT NULL` | Judul catatan / tugas (wajib diisi, min. 3 karakter) |
| `description` | `TEXT` | Rincian atau catatan tambahan (opsional) |
| `category` | `TEXT NOT NULL` | Kategori (Kuliah, Tugas, Pekerjaan, Pribadi, Lainnya) |
| `priority` | `TEXT NOT NULL` | Tingkat prioritas (Tinggi, Sedang, Rendah) |
| `due_date` | `TEXT` | Tanggal tenggat waktu format YYYY-MM-DD |
| `is_completed` | `INTEGER NOT NULL DEFAULT 0` | Status selesai: 0 (Belum), 1 (Selesai) |
| `created_at` | `TEXT NOT NULL` | Tanggal dan waktu pembuatan format ISO-8601 |

---

## BAB III: PENJELASAN IMPLEMENTASI KODE PROGRAM

### 3.1 Model Data (`lib/models/todo_item.dart`)
Kelas `TodoItem` berfungsi sebagai cetak biru data tugas. Di dalamnya terdapat fungsi `toMap()` untuk mengonversi objek Dart menjadi representasi Map yang dapat diproses oleh query SQL `INSERT` atau `UPDATE`, serta `fromMap()` untuk membaca data dari hasil query `SELECT`.

### 3.2 Database Helper (`lib/helpers/db_helper.dart`)
Menerapkan *Singleton Pattern* untuk memastikan hanya ada satu instance koneksi database yang aktif:
- `_initDb()`: Melakukan inisialisasi database SQLite dan mendaftarkan driver FFI jika dijalankan pada lingkungan desktop/test.
- `insertTodo(TodoItem todo)`: Menjalankan `db.insert('todos', todo.toMap())`.
- `getTodos({searchQuery, statusFilter, categoryFilter})`: Melakukan query data dinamis dengan klausul `WHERE LOWER(title) LIKE ?`, filter `is_completed`, dan filter `category`.
- `updateTodo(TodoItem todo)`: Menjalankan `db.update` berdasarkan ID tugas.
- `toggleTodoStatus(int id, bool isCompleted)`: Memperbarui kolom `is_completed` secara instan.
- `deleteTodo(int id)`: Menghapus baris catatan dari database SQLite.
- `getStats()`: Menghitung jumlah total tugas, tugas selesai, dan tugas tertunda untuk *dashboard*.

### 3.3 Halaman Utama (`lib/ui/todo_page.dart`)
- **Search Bar:** Menggunakan `TextEditingController` dengan event `onChanged` sehingga penyaringan judul terjadi secara langsung tanpa perlu tombol cari terpisah.
- **Statistik Mini:** Menampilkan kartu ringkasan jumlah tugas (Total, Tertunda, Selesai) dengan gradien warna modern.
- **Filter Chips:** Memungkinkan pengguna menyaring data berdasarkan status (Semua / Belum Selesai / Selesai) dan kategori tugas.
- **RefreshIndicator:** Mendukung fitur *pull-to-refresh* untuk memuat ulang data dari SQLite.

### 3.4 Formulir Tambah & Edit (`lib/ui/todo_form.dart`)
- Memvalidasi isian pengguna menggunakan `_formKey.currentState!.validate()`. Jika judul kosong atau kurang dari 3 karakter, akan muncul pesan error di bawah textfield serta `WarningDialog`.
- Menggunakan `showDatePicker` bawaan Flutter untuk pemilihan tanggal tenggat waktu secara akurat dan mudah.
- Menggunakan `SuccessDialog` kustom saat penyimpanan berhasil dilakukan, kemudian kembali ke halaman utama untuk memicu pembaruan data secara otomatis.

### 3.5 Halaman Detail & Dialog Konfirmasi (`lib/ui/todo_detail.dart`)
- Menampilkan seluruh rincian informasi tugas, status penyelesaian, kategori, prioritas, tanggal tenggat waktu, dan waktu pembuatan.
- Menyediakan tombol cepat untuk mengubah status selesai / belum selesai.
- Aksi hapus dilindungi dengan `ConfirmDialog` agar pengguna tidak sengaja menghapus data penting.

---

## BAB IV: PENGUJIAN DAN HASIL (TESTING)

### 4.1 Pengujian Statis (Static Code Analysis)
Perintah pengujian:
```bash
flutter analyze
```
**Hasil:**
```text
Analyzing to-do-list...
No issues found! (ran in 1.9s)
```
Kode program 100% bersih dari pesan error, warning linter, maupun *deprecated members*.

### 4.2 Pengujian Otomatis (Unit & Widget Testing)
Pengujian otomatis dilakukan pada:
1. `test/todo_model_test.dart`: Menguji pembuatan objek, default values, serialisasi `toMap()`, deserialisasi `fromMap()`, dan fungsi `copyWith()`.
2. `test/db_helper_test.dart`: Menguji seluruh siklus operasi CRUD (Create, Read, Search, Update, Toggle, Delete, Stats) langsung pada SQLite database engine.
3. `test/widget_test.dart`: Menguji perenderan antarmuka utama `TodoPage`, AppBar, floating action button, dan search bar.

Perintah pengujian:
```bash
flutter test
```
**Hasil:**
```text
00:01 +5: All tests passed!
```
Semua 5 skenario pengujian berhasil lulus (*Passed*) dengan sempurna.

### 4.3 Pengujian Fungsional Fitur
| No | Skenario Uji | Tindakan Pengujian | Hasil yang Diharapkan | Status |
|---|---|---|---|---|
| 1 | Tambah Tugas Baru | Mengisi judul, kategori, prioritas, deadline lalu klik Simpan | Data tersimpan di SQLite, muncul dialog sukses, data tampil di list | **BERHASIL** |
| 2 | Validasi Form Kosong | Mengosongkan judul lalu klik Simpan | Muncul pesan error validasi dan dialog peringatan | **BERHASIL** |
| 3 | Tampil & Baca Data | Membuka halaman utama aplikasi | Seluruh daftar tugas termuat beserta rincian ringkasnya | **BERHASIL** |
| 4 | Pencarian Judul | Mengetik kata kunci judul pada kotak pencarian | Daftar tugas otomatis terfilter sesuai kata kunci secara instan | **BERHASIL** |
| 5 | Filter Status & Kategori | Mengklik chip 'Selesai' atau memilih kategori | Hanya menampilkan tugas yang sesuai dengan kriteria filter | **BERHASIL** |
| 6 | Ubah / Edit Tugas | Mengubah judul, rincian, atau tanggal deadline | Perubahan data tersimpan ke SQLite dan langsung terbarui di layar | **BERHASIL** |
| 7 | Toggle Status Checklist | Mengklik kotak centang / checkbox pada item tugas | Status berubah (coret teks) dan angka statistik terbarui | **BERHASIL** |
| 8 | Hapus Tugas | Memilih menu hapus dan konfirmasi pada dialog | Data terhapus permanen dari SQLite dan hilang dari daftar | **BERHASIL** |
| 9 | Persistensi Data Lokal | Menutup aplikasi sepenuhnya, lalu membuka kembali | Data tetap tersimpan utuh dan tidak hilang | **BERHASIL** |

---

## BAB V: KESIMPULAN

Aplikasi **Quick Notes & To-Do List** telah berhasil dibangun menggunakan framework Flutter dan bahasa pemrograman Dart sesuai spesifikasi soal **Kasus 2 UTS Pemrograman Mobile Lanjut (INF3022)**. Seluruh fitur minimal yang dipersyaratkan (CRUD lengkap, pencarian judul real-time, validasi formulir dengan `TextEditingController`, serta penyimpanan lokal persisten dengan `sqflite`) berjalan dengan stabil dan lancar. 

Penerapan *clean architecture* dan pemisahan modul yang terstruktur mempermudah pemeliharaan serta pengembangan fitur aplikasi di masa mendatang.

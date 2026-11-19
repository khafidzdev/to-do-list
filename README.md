# 📱 Quick Notes & To-Do List (Penyimpanan Lokal SQLite)

> **Projek Ujian Tengah Semester (UTS) Ganjil TA 2026/2027**  
> **Mata Kuliah:** Pemrograman Mobile Lanjut (Kode MK: INF3022)  
> **Dosen Pengampu:** Eko Budihartono, S.T., M.Kom.  
> **Program Studi:** S1 Teknik Informatika, Fakultas Sains & Teknologi  
> **Topik Dipilih:** **Kasus 2: Quick Notes & To-Do List (Penyimpanan Lokal)**  

---

## 📖 Deskripsi Aplikasi

Aplikasi **Quick Notes & To-Do List** adalah aplikasi produktivitas berbasis mobile (Flutter & Dart) yang dirancang untuk mengelola catatan cepat, agenda, dan tugas harian secara efisien dan persisten. Seluruh data disimpan secara lokal pada perangkat menggunakan basis data **SQLite (`sqflite`)**, sehingga data tidak hilang saat aplikasi ditutup maupun saat perangkat dihidupkan ulang (*offline-first*).

Aplikasi ini dibangun dengan mengikuti standar modul perkuliahan **Pemrograman Mobile Lanjut**, menerapkan arsitektur modular yang rapi (*clean code*), pemisahan komponen UI, logic, helper database, serta model data yang terstruktur.

---

## ✨ Fitur-Fitur Utama

1. **Operasi CRUD Lengkap (Create, Read, Update, Delete):**
   - **Create (Tambah):** Menambahkan tugas/catatan baru lengkap dengan judul, deskripsi, kategori, tingkat prioritas, dan tenggat waktu (*deadline*).
   - **Read (Tampil):** Menampilkan daftar tugas dengan kartu interaktif (*card*), indikator warna prioritas, tag kategori, tanggal, serta halaman detail rincian tugas.
   - **Update (Ubah):** Mengedit isi tugas, mengganti kategori/prioritas/tanggal, serta mengubah status tugas (*checkbox/switch toggle* selesai/belum selesai).
   - **Delete (Hapus):** Menghapus catatan/tugas dengan dialog konfirmasi aman untuk mencegah penghapusan data secara tidak sengaja.

2. **Fitur Pencarian Judul Real-Time (Search Bar):**
   - Kotak pencarian interaktif di bagian atas layar menggunakan `TextEditingController`.
   - Melakukan filter instan judul catatan secara *case-insensitive* langsung ke query SQLite.

3. **Penyimpanan Lokal Persisten (SQLite / `sqflite`):**
   - Menggunakan file database lokal `todo_app.db`.
   - Data otomatis tersimpan di memori perangkat Android dan dimuat kembali setiap kali aplikasi dijalankan.

4. **Widget Ringkasan Statistik (*Dashboard Mini*):**
   - Menampilkan total tugas, jumlah tugas tertunda (*pending*), dan tugas yang sudah selesai (*completed*) secara langsung.

5. **Sistem Filter Cepat (Status & Kategori):**
   - Filter Status: *Semua*, *Belum Selesai*, dan *Selesai*.
   - Filter Kategori: *Semua*, *Kuliah*, *Tugas*, *Pekerjaan*, *Pribadi*, dan *Lainnya*.

6. **Form Validation & Dialogs:**
   - Validasi ketat menggunakan `GlobalKey<FormState>` (judul wajib diisi, minimal 3 karakter).
   - Dialog peringatan (`WarningDialog`) dan dialog sukses (`SuccessDialog`) dengan gaya kustom sesuai modul praktikum.
   - Dialog konfirmasi (`ConfirmDialog`) sebelum menghapus catatan.

---

## 📂 Struktur Direktori Proyek

```text
to-do-list/
├── lib/
│   ├── main.dart               # Entry point aplikasi, tema Material 3, inisialisasi FFI/DB
│   ├── models/
│   │   └── todo_item.dart      # Model data tugas (fromJson, toJson, toMap, fromMap)
│   ├── helpers/
│   │   └── db_helper.dart      # Singleton SQLite Database Helper (CRUD & Query logic)
│   ├── ui/
│   │   ├── todo_page.dart      # Halaman utama (Dashboard, Search, Filter, List view)
│   │   ├── todo_form.dart      # Halaman formulir tambah & edit tugas (Form validation)
│   │   └── todo_detail.dart    # Halaman detail rincian tugas & kontrol status
│   └── widgets/
│       ├── todo_card.dart      # Komponen kartu item tugas interaktif
│       ├── success_dialog.dart # Dialog notifikasi berhasil (sesuai modul)
│       ├── warning_dialog.dart # Dialog notifikasi peringatan/validasi (sesuai modul)
│       └── confirm_dialog.dart # Dialog konfirmasi aksi penghapusan
├── test/
│   ├── todo_model_test.dart    # Unit test untuk Model TodoItem
│   ├── db_helper_test.dart     # Unit test CRUD SQLite Database
│   └── widget_test.dart        # Widget test untuk antarmuka UI utama
├── pubspec.yaml                # Konfigurasi dependensi proyek
└── README.md                   # Dokumentasi lengkap proyek
```

---

## 🛠️ Dependensi Paket

| Paket | Versi | Kegunaan |
|---|---|---|
| `flutter` | SDK | Framework UI multiplatform |
| `sqflite` | `^2.4.6` | Plugin basis data SQLite untuk persistensi lokal di Android & iOS |
| `sqflite_common_ffi` | `^2.4.7` | Dukungan FFI SQLite untuk Linux Desktop & Unit Testing otomatis |
| `path` | `^1.9.1` | Utilitas manipulasi path berkas database lokal |
| `intl` | `^0.20.3` | Format tanggal dan waktu (DatePicker & tampilan deadline) |
| `cupertino_icons` | `^1.0.8` | Koleksi ikon standar |

---

## 🚀 Cara Menjalankan Proyek

### 1. Prasyarat
- Flutter SDK (versi 3.10.0 atau lebih baru)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK (API 26 / Android 8.0 Oreo ke atas) atau perangkat fisik Android yang telah mengaktifkan *USB Debugging*.

### 2. Langkah Menjalankan
Buka terminal pada direktori proyek:

```bash
# 1. Unduh seluruh dependensi
flutter pub get

# 2. Periksa kesiapan kode (Linter)
flutter analyze

# 3. Jalankan pengujian otomatis (Unit Test & Widget Test)
flutter test

# 4. Jalankan aplikasi pada perangkat Android atau Emulator
flutter run
```

### 3. Kompilasi APK (Android)
Untuk menghasilkan berkas `.apk` instalasi:

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```
Berkas APK akan berada pada direktori: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 🧪 Hasil Pengujian (Testing)

Semua pengujian telah diverifikasi dan berjalan sukses tanpa kendala:
- **`flutter analyze`:** `No issues found!` (0 error, 0 warning).
- **`flutter test`:** 5/5 pengujian lulus mencakup validasi model `TodoItem`, operasi CRUD `DbHelper`, dan *smoke test* rendering antarmuka `TodoPage`.

---

## 👥 Identitas Mahasiswa

- **Nama Mahasiswa:** [Nama Anda / Anggota Kelompok]
- **NIM:** [NIM Anda / Anggota Kelompok]
- **Kelas:** [Kelas A / RM]
- **Program Studi:** S1 Teknik Informatika
- **Tahun Akademik:** 2026/2027

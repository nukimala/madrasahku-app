# Dokumentasi Perubahan & Sinkronisasi Data (Madrasahku App)

Dokumentasi ini merangkum perbaikan dan sinkronisasi relasi data antara **Guru $\rightarrow$ Kelas & Mapel** serta **Siswa $\rightarrow$ Kelas $\rightarrow$ Penerimaan Materi**, agar alur aplikasi berjalan dinamis sesuai data di database server.

---

## 📋 1. Ringkasan Masalah Sebelumnya
- **Kelas Siswa Hardcode:** Pada halaman materi siswa (`MateriPage`), nama kelas masih di-*hardcode* (`'Kelas VIII A'`) dan belum terhubung ke data akun siswa yang sedang login.
- **List Mapel Statis:** Dropdown mata pelajaran di sisi siswa menggunakan list statis string biasa, sehingga rentan terjadi *mismatch* (perbedaan penulisan nama mapel) dengan data dari database server.
- **Parameter Filter API:** Service pemanggil data (`MateriService`) belum mendukung parameter spesifik kelas saat mengambil data materi dari backend.

---

## 🛠️ 2. Detail Perubahan Kode

### A. Memperbarui `MateriService`
* **File:** `lib/services/materi_service.dart`
* **Perubahan:** Menambahkan parameter opsional `int? classId` pada fungsi `ambilDaftarMateri()` agar request ke endpoint `/materials` dapat difilter berdasarkan ID kelas jika diperlukan.
* **Kutipan Kode:**
```dart
Future<List<MateriItem>> ambilDaftarMateri({int? classId}) async {
  final params = <String, String>{};
  if (classId != null && classId > 0) {
    params['class_id'] = classId.toString();
  }

  final res = await ApiClient.instance.get(
    '/materials',
    queryParams: params.isNotEmpty ? params : null,
  );
  // ... parsing data ...
}
```

---

### B. Membuat Dinamis Halaman Materi Siswa (`MateriPage`)
* **File:** `lib/screens/siswa/Materi/materi_page.dart`
* **Perubahan:**
  1. Mengambil data kelas siswa yang sedang aktif secara otomatis dari `AuthService.instance.currentUser?.kelas`.
  2. Mengubah daftar mata pelajaran (`_mapelList`) menjadi dinamis berdasarkan data `subjectName` yang dikembalikan oleh server.
  3. Menambahkan indikator loading (`CircularProgressIndicator`) saat mengambil data dari API.
* **Kutipan Kode:**
```dart
Future<void> _muatDataDanMateri() async {
  setState(() => _loading = true);
  try {
    // 1. Ambil kelas dari user yang login
    final authUser = AuthService.instance.currentUser;
    if (authUser != null && authUser.kelas.isNotEmpty) {
      _kelas = authUser.kelas;
    }

    // 2. Ambil daftar materi dari API
    final items = await MateriService.instance.ambilDaftarMateri();
    // ... menyusun mapel dan topik secara dinamis ...
    setState(() => _loading = false);
  } catch (_) {
    if (mounted) setState(() => _loading = false);
  }
}
```

---

## 🛠️ 3. Perbaikan Relasi Tugas Siswa
* **File:** `lib/services/tugas_service.dart` dan `lib/screens/siswa/tugas/tugas_page.dart`
* **Masalah:** Sama seperti materi, daftar tugas sebelumnya diambil secara global tanpa filter kelas yang spesifik untuk siswa.
* **Solusi:** 
  1. Menambahkan dukungan parameter `classId` di `TugasService`.
  2. Mengintegrasikan `AuthService` di `TugasPage` untuk persiapan filter tugas berbasis kelas siswa yang sedang login.
  3. Memastikan status tugas (Aktif/Selesai/Terlambat) terdeteksi otomatis dari response API.

---

## 🔍 5. Analisis Kebutuhan & Konfirmasi Fitur
Berdasarkan diskusi terbaru, fitur **Penilaian (Grading)** oleh guru sengaja ditiadakan dalam aplikasi ini. Fokus utama tetap pada fungsionalitas manajemen pembelajaran dan presensi. Berikut poin selarasnya:

1. **Alur Tugas Sederhana:** Tugas berfungsi sebagai media pengiriman instruksi dari Guru dan pengumpulan file dari Siswa. Status "Selesai" didasarkan pada aktivitas pengumpulan file oleh siswa.
2. **Sinkronisasi ID Profil:** Memastikan `user_id` saat login terhubung dengan `teacher_id` atau `student_id` yang benar agar relasi data (Siapa yang buat materi/siapa yang kumpul tugas) valid secara database.
3. **Konsistensi Radius Presensi:** Radius di kode Flutter (20m) perlu dikonfirmasi kembali dengan dokumen teknis (10m) untuk menjaga konsistensi spesifikasi keamanan.
4. **Monitoring Admin:** Admin tetap memiliki akses untuk melihat rekap kehadiran guru yang valid berdasarkan QR dan GPS.
1. **Pemisahan Peran (Role-based):** Menunjukkan bahwa aplikasi Madrasahku tidak lagi menggunakan data tiruan (*mock*) statis, melainkan sudah membaca sesi pengguna yang sedang login (baik sebagai Admin, Guru, maupun Siswa).
2. **Koneksi Frontend & Backend:** Memastikan bahwa filter kelas dan mata pelajaran pada menu materi dan tugas benar-benar selaras dengan penugasan guru dan kelas siswa di database.
3. **User Experience (UX):** Penambahan indikator loading dan penyesuaian otomatis dropdown mapel membuat aplikasi lebih responsif dan tahan terhadap perbedaan data di server.

const _bulanPendek = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const _bulanPanjang = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _jam(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

// Contoh: 11 Des 2026 23.59
String formatTglJamPendek(DateTime d) =>
    '${d.day} ${_bulanPendek[d.month - 1]} ${d.year} ${_jam(d)}';

// Contoh: 11 Desember 2026, 23.59
String formatTglJamPanjang(DateTime d) =>
    '${d.day} ${_bulanPanjang[d.month - 1]} ${d.year}, ${_jam(d)}';


enum StatusSiswa { selesai, terlambat, belum }

class SiswaTugas {
  final String nama;
  DateTime? waktuKumpul; // null = belum mengumpulkan

  SiswaTugas({required this.nama, this.waktuKumpul});
}

class TugasGuru {
  final String judul;
  final DateTime deadline;
  final List<SiswaTugas> siswa;

  TugasGuru({
    required this.judul,
    required this.deadline,
    List<SiswaTugas>? siswa,
  }) : siswa = siswa ?? [];

  StatusSiswa statusDari(SiswaTugas s) {
    if (s.waktuKumpul == null) return StatusSiswa.belum;

    return s.waktuKumpul!.isAfter(deadline)
        ? StatusSiswa.terlambat
        : StatusSiswa.selesai;
  }
}

class TopikTugas {
  final int minggu;
  final String nama;
  final String kelas;
  final String mapel;
  final List<TugasGuru> tugas;

  TopikTugas({
    required this.minggu,
    required this.nama,
    required this.kelas,
    required this.mapel,
    List<TugasGuru>? tugas,
  }) : tugas = tugas ?? [];

  String get judul => 'Minggu $minggu - $nama';
}

List<TopikTugas> contohTopikTugas() {
  final deadline = DateTime(2026, 12, 11, 23, 59);

  return [
    TopikTugas(
      minggu: 1,
      nama: 'Persamaan Linear',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
      tugas: [
        TugasGuru(
          judul: 'Persamaan Linear',
          deadline: deadline,
          siswa: [
            SiswaTugas(nama: 'Shofi maulana Shofa', waktuKumpul: DateTime(2026, 12, 12, 10, 12)),
            SiswaTugas(nama: 'Dinda Febiola', waktuKumpul: DateTime(2026, 12, 11, 10, 12)),
            SiswaTugas(nama: 'Repaldtt', waktuKumpul: DateTime(2026, 12, 12, 8, 30)),
            SiswaTugas(nama: 'Afif Ramdhani', waktuKumpul: DateTime(2026, 12, 10, 10, 12)),
            SiswaTugas(nama: 'Adam Ridho', waktuKumpul: DateTime(2026, 12, 10, 9, 0)),
            SiswaTugas(nama: 'Angello Eriya', waktuKumpul: DateTime(2026, 12, 12, 9, 15)),
            SiswaTugas(nama: 'Etnis Supraaaa', waktuKumpul: DateTime(2026, 12, 13, 7, 45)),
            SiswaTugas(nama: 'Ryan', waktuKumpul: DateTime(2026, 12, 11, 12, 0)),
            SiswaTugas(nama: 'Shulki'),
          ],
        ),
        TugasGuru(
          judul: 'Persamaan Parabola',
          deadline: deadline,
          siswa: [
            SiswaTugas(nama: 'Dinda Febiola', waktuKumpul: DateTime(2026, 12, 11, 9, 0)),
            SiswaTugas(nama: 'Adam Ridho'),
            SiswaTugas(nama: 'Shulki'),
          ],
        ),
      ],
    ),
    TopikTugas(minggu: 3, nama: 'FPB dan KPK', kelas: 'Kelas VIII A', mapel: 'Matematika'),
    TopikTugas(minggu: 4, nama: 'Desimal', kelas: 'Kelas VIII A', mapel: 'Matematika'),
  ];
}

class TugasItem {
  final int id;
  final String publicId;
  final String title;
  final String? instructions;
  final String deadline;
  final String subjectName;
  final String className;
  final String teacherName;
  final bool isSubmitted;
  final int? score;
  final String? teacherFeedback;

  const TugasItem({
    required this.id,
    required this.publicId,
    required this.title,
    this.instructions,
    required this.deadline,
    required this.subjectName,
    required this.className,
    required this.teacherName,
    this.isSubmitted = false,
    this.score,
    this.teacherFeedback,
  });

  factory TugasItem.fromJson(Map<String, dynamic> json) {
    final sub = json['my_submission'];
    return TugasItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      publicId: json['public_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      instructions: json['instructions'],
      deadline: json['deadline'] ?? '',
      subjectName: json['subject_name'] ?? '',
      className: json['class_name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      isSubmitted: sub != null,
      score: sub is Map && sub['score'] != null
          ? int.tryParse(sub['score'].toString())
          : null,
      teacherFeedback: sub is Map ? sub['teacher_feedback']?.toString() : null,
    );
  }
}

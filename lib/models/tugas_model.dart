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

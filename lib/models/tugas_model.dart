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
  final TugasItem? tugasItem;

  TugasGuru({
    required this.judul,
    required this.deadline,
    List<SiswaTugas>? siswa,
    this.tugasItem,
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
  final int classId; // <-- TAMBAHAN: numeric class ID untuk fetch siswa
  final String teacherName;
  final bool isSubmitted;
  final int? score;
  final String? teacherFeedback;
  final int? topicId;
  final int? topicMinggu;
  final String? topicNama;

  const TugasItem({
    required this.id,
    required this.publicId,
    required this.title,
    this.instructions,
    required this.deadline,
    required this.subjectName,
    required this.className,
    required this.classId,
    required this.teacherName,
    this.isSubmitted = false,
    this.score,
    this.teacherFeedback,
    this.topicId,
    this.topicMinggu,
    this.topicNama,
  });

  factory TugasItem.fromJson(Map<String, dynamic> json) {
    final sub = json['my_submission'];
    final cls = json['class'];
    final subj = json['subject'];
    final topic = json['topic'];
    return TugasItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      publicId: (json['public_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      instructions: (json['description'] ?? json['instructions'])?.toString(),
      deadline: (json['due_at'] ?? json['deadline'] ?? '').toString(),
      subjectName: subj is Map
          ? (subj['name'] ?? '').toString()
          : (json['subject_name'] ?? '').toString(),
      className: cls is Map
          ? (cls['name'] ?? '').toString()
          : (json['class_name'] ?? '').toString(),
      classId: cls is Map
          ? (cls['id'] is int ? cls['id'] as int : int.tryParse(cls['id']?.toString() ?? '') ?? 0)
          : (json['class_id'] is int
              ? json['class_id'] as int
              : int.tryParse(json['class_id']?.toString() ?? '') ?? 0),
      teacherName: (json['teacher_name'] ?? json['author_name'] ?? '').toString(),
      isSubmitted: sub != null,
      score: sub is Map && sub['score'] != null
          ? (double.tryParse(sub['score'].toString())?.round())
          : null,
      teacherFeedback: sub is Map
          ? (sub['feedback'] ?? sub['teacher_feedback'])?.toString()
          : null,
      topicId: topic is Map
          ? (topic['id'] is int ? topic['id'] as int : int.tryParse(topic['id']?.toString() ?? ''))
          : null,
      topicMinggu: topic is Map
          ? (topic['minggu'] is int ? topic['minggu'] as int : int.tryParse(topic['minggu']?.toString() ?? ''))
          : null,
      topicNama: topic is Map ? topic['nama']?.toString() : null,
    );
  }
}

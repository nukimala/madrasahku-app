enum Semester {
  ganjil('Ganjil'),
  genap('Genap');

  final String label;

  const Semester(this.label);
}

enum HariSekolah {
  senin('Senin'),
  selasa('Selasa'),
  rabu('Rabu'),
  kamis('Kamis'),
  jumat('Jumat'),
  sabtu('Sabtu');

  final String label;

  const HariSekolah(this.label);
}

class JadwalPelajaran {
  final int id;
  final String tahunAjaran;
  final Semester semester;
  final String? kelas;
  final HariSekolah hari;
  final int? mulaiMenit;
  final int? selesaiMenit;
  final String? jamKe;
  final String mataPelajaran;
  final String? kodeMapel;
  final String guru;
  final String? kodeGuru;
  final String? ruang;

  const JadwalPelajaran({
    required this.id,
    required this.tahunAjaran,
    required this.semester,
    this.kelas,
    required this.hari,
    required this.mulaiMenit,
    required this.selesaiMenit,
    this.jamKe,
    required this.mataPelajaran,
    this.kodeMapel,
    required this.guru,
    this.kodeGuru,
    this.ruang,
  });

  String get tampilanWaktu {
    if (mulaiMenit != null && selesaiMenit != null) {
      return '${formatMenit(mulaiMenit!)}–${formatMenit(selesaiMenit!)}';
    }
    if (jamKe != null && jamKe!.isNotEmpty) return 'Jam $jamKe';
    return 'Waktu belum diatur';
  }

  String get tampilanLokasi => [
    if (kelas != null && kelas!.isNotEmpty) 'Kelas $kelas',
    if (ruang != null && ruang!.isNotEmpty) ruang!,
  ].join(' · ');

  JadwalPelajaran copyWith({
    int? id,
    String? tahunAjaran,
    Semester? semester,
    String? kelas,
    HariSekolah? hari,
    int? mulaiMenit,
    int? selesaiMenit,
    String? jamKe,
    String? mataPelajaran,
    String? kodeMapel,
    String? guru,
    String? kodeGuru,
    String? ruang,
  }) => JadwalPelajaran(
    id: id ?? this.id,
    tahunAjaran: tahunAjaran ?? this.tahunAjaran,
    semester: semester ?? this.semester,
    kelas: kelas ?? this.kelas,
    hari: hari ?? this.hari,
    mulaiMenit: mulaiMenit ?? this.mulaiMenit,
    selesaiMenit: selesaiMenit ?? this.selesaiMenit,
    jamKe: jamKe ?? this.jamKe,
    mataPelajaran: mataPelajaran ?? this.mataPelajaran,
    kodeMapel: kodeMapel ?? this.kodeMapel,
    guru: guru ?? this.guru,
    kodeGuru: kodeGuru ?? this.kodeGuru,
    ruang: ruang ?? this.ruang,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'tahunAjaran': tahunAjaran,
    'semester': semester.name,
    'kelas': kelas,
    'hari': hari.name,
    'mulaiMenit': mulaiMenit,
    'selesaiMenit': selesaiMenit,
    'jamKe': jamKe,
    'mataPelajaran': mataPelajaran,
    'kodeMapel': kodeMapel,
    'guru': guru,
    'kodeGuru': kodeGuru,
    'ruang': ruang,
  };

  factory JadwalPelajaran.fromJson(Map<String, dynamic> json) =>
      JadwalPelajaran(
        id: json['id'] as int,
        tahunAjaran: json['tahunAjaran'] as String,
        semester: Semester.values.byName(json['semester'] as String),
        kelas: json['kelas'] as String?,
        hari: HariSekolah.values.byName(json['hari'] as String),
        mulaiMenit: json['mulaiMenit'] as int?,
        selesaiMenit: json['selesaiMenit'] as int?,
        jamKe: json['jamKe'] as String?,
        mataPelajaran: json['mataPelajaran'] as String,
        kodeMapel: json['kodeMapel'] as String?,
        guru: json['guru'] as String,
        kodeGuru: json['kodeGuru'] as String?,
        ruang: json['ruang'] as String?,
      );
}

String formatMenit(int menit) {
  final jam = (menit ~/ 60).toString().padLeft(2, '0');
  final sisaMenit = (menit % 60).toString().padLeft(2, '0');
  return '$jam.$sisaMenit';
}

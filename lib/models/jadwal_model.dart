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
  final String kelas;
  final HariSekolah hari;
  final int mulaiMenit;
  final int selesaiMenit;
  final String mataPelajaran;
  final String guru;
  final String ruang;

  const JadwalPelajaran({
    required this.id,
    required this.tahunAjaran,
    required this.semester,
    required this.kelas,
    required this.hari,
    required this.mulaiMenit,
    required this.selesaiMenit,
    required this.mataPelajaran,
    required this.guru,
    required this.ruang,
  });

  JadwalPelajaran copyWith({
    int? id,
    String? tahunAjaran,
    Semester? semester,
    String? kelas,
    HariSekolah? hari,
    int? mulaiMenit,
    int? selesaiMenit,
    String? mataPelajaran,
    String? guru,
    String? ruang,
  }) => JadwalPelajaran(
    id: id ?? this.id,
    tahunAjaran: tahunAjaran ?? this.tahunAjaran,
    semester: semester ?? this.semester,
    kelas: kelas ?? this.kelas,
    hari: hari ?? this.hari,
    mulaiMenit: mulaiMenit ?? this.mulaiMenit,
    selesaiMenit: selesaiMenit ?? this.selesaiMenit,
    mataPelajaran: mataPelajaran ?? this.mataPelajaran,
    guru: guru ?? this.guru,
    ruang: ruang ?? this.ruang,
  );
}

String formatMenit(int menit) {
  final jam = (menit ~/ 60).toString().padLeft(2, '0');
  final sisaMenit = (menit % 60).toString().padLeft(2, '0');
  return '$jam.$sisaMenit';
}

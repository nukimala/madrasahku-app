class KelasItem {
  final int? id;
  final String nama;
  final String tingkat;
  final String? waliKelas;
  final String tahunAjaran;
  final int jumlahSiswa;

  const KelasItem({
    this.id,
    required this.nama,
    required this.tingkat,
    required this.waliKelas,
    required this.tahunAjaran,
    this.jumlahSiswa = 0,
  });

  factory KelasItem.fromJson(Map<String, dynamic> json) {
    return KelasItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nama: (json['nama_kelas'] ?? json['name'] ?? '').toString(),
      tingkat: (json['tingkat'] ?? json['level'] ?? '7').toString(),
      waliKelas: json['wali_kelas']?.toString(),
      tahunAjaran: (json['tahun_ajaran'] ?? '2026/2027').toString(),
      jumlahSiswa: json['jumlah_siswa'] is int
          ? json['jumlah_siswa'] as int
          : int.tryParse(json['jumlah_siswa']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_kelas': nama,
        'tingkat': int.tryParse(tingkat) ?? 7,
        if (waliKelas != null && waliKelas!.isNotEmpty) 'wali_kelas': waliKelas,
      };
}
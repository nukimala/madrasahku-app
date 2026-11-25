const kelompokPai = 'Pendidikan Agama Islam (PAI) & Bahasa Arab';
const kelompokUmum = 'Mata Pelajaran Umum';

class MapelItem {
  final int? id;
  final String nama;
  final String kode;
  final String deskripsi;
  final String kelompok;
  final bool aktif;

  const MapelItem({
    this.id,
    required this.nama,
    required this.kode,
    required this.deskripsi,
    required this.kelompok,
    this.aktif = true,
  });

  factory MapelItem.fromJson(Map<String, dynamic> json) {
    final rawGroup = (json['kelompok'] ?? json['group'] ?? 'umum').toString().toLowerCase();
    final isPai = rawGroup.contains('agama') || rawGroup.contains('pai');
    return MapelItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nama: (json['nama_mapel'] ?? json['name'] ?? '').toString(),
      kode: (json['kode_mapel'] ?? json['code'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      kelompok: isPai ? kelompokPai : kelompokUmum,
      aktif: json['is_active'] == null || json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_mapel': nama,
        'kode_mapel': kode,
        'kelompok': kelompok == kelompokPai ? 'agama' : 'umum',
      };

  MapelItem copyWith({bool? aktif}) => MapelItem(
        id: id,
        nama: nama,
        kode: kode,
        deskripsi: deskripsi,
        kelompok: kelompok,
        aktif: aktif ?? this.aktif,
      );
}

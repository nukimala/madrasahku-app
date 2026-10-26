const kelompokPai = 'Pendidikan Agama Islam (PAI) & Bahasa Arab';
const kelompokUmum = 'Mata Pelajaran Umum';

class MapelItem {
  final String nama;
  final String kode;
  final String deskripsi;
  final String kelompok;
  final bool aktif;

  const MapelItem({
    required this.nama,
    required this.kode,
    required this.deskripsi,
    required this.kelompok,
    this.aktif = true,
  });

  MapelItem copyWith({bool? aktif}) => MapelItem(
        nama: nama,
        kode: kode,
        deskripsi: deskripsi,
        kelompok: kelompok,
        aktif: aktif ?? this.aktif,
      );
}

class KelasItem {
  final String nama;
  final String tingkat;
  final String waliKelas;
  final String tahunAjaran;
  final int jumlahSiswa;
  final bool aktif;

  const KelasItem({
    required this.nama,
    required this.tingkat,
    required this.waliKelas,
    required this.tahunAjaran,
    this.jumlahSiswa = 0,
    this.aktif = true,
  });

  KelasItem copyWith({bool? aktif}) => KelasItem(
        nama: nama,
        tingkat: tingkat,
        waliKelas: waliKelas,
        tahunAjaran: tahunAjaran,
        jumlahSiswa: jumlahSiswa,
        aktif: aktif ?? this.aktif,
      );
}
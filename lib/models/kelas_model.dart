class KelasItem {
  final String nama;
  final String tingkat;
  final String? waliKelas;
  final String tahunAjaran;
  final int jumlahSiswa;

  const KelasItem({
    required this.nama,
    required this.tingkat,
    required this.waliKelas,
    required this.tahunAjaran,
    this.jumlahSiswa = 0,
  });
}
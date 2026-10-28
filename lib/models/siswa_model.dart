class SiswaItem {
  final String nama;
  final String nis;
  final String kelas;
  final String jenisKelamin;
  final String tanggalLahir;
  final bool aktif;

  const SiswaItem({
    required this.nama,
    required this.kelas,
    this.nis = '',
    this.jenisKelamin = '',
    this.tanggalLahir = '',
    this.aktif = true,
  });
}
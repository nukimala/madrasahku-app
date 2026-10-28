class GuruItem {
  final String nama;
  final String nipNuptk;
  final String mapel;
  final String email;
  final String telepon;
  final bool aktif;

  const GuruItem({
    required this.nama,
    required this.mapel,
    this.nipNuptk = '',
    this.email = '',
    this.telepon = '',
    this.aktif = true,
  });
}
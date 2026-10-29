class PresensiService {
  static final PresensiService instance = PresensiService._();
  PresensiService._();

  bool _sudahPresensi = false;
  bool get sudahPresensi => _sudahPresensi;

  void catatPresensi() {
    _sudahPresensi = true;
  }
}

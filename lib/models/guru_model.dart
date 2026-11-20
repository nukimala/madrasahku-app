class GuruItem {
  final int? id;
  final String nama;
  final String nipNuptk;
  final String mapel;
  final String email;
  final String telepon;
  final String gender;
  final String alamat;
  final bool aktif;

  const GuruItem({
    this.id,
    required this.nama,
    required this.mapel,
    this.nipNuptk = '',
    this.email = '',
    this.telepon = '',
    this.gender = 'L',
    this.alamat = '',
    this.aktif = true,
  });

  factory GuruItem.fromJson(Map<String, dynamic> j) {
    final nip = (j['nip'] ?? '').toString();
    final nuptk = (j['nuptk'] ?? '').toString();
    final nipNuptk = (j['nip_nuptk'] ?? (nip.isNotEmpty ? nip : nuptk)).toString();

    final namaVal = (j['nama_lengkap'] ?? j['nama'] ?? '').toString();
    final mapelVal = (j['bidang_studi'] ?? j['subject_specialty'] ?? j['mapel'] ?? '').toString();
    final telpVal = (j['no_hp'] ?? j['phone'] ?? j['telepon'] ?? '').toString();
    final emailVal = (j['email'] ?? '').toString();
    final genderVal = (j['gender'] ?? j['jenis_kelamin'] ?? 'L').toString();
    final alamatVal = (j['alamat'] ?? j['address'] ?? '').toString();

    final activeVal = j['is_active'];
    final bool isActive = activeVal == 1 || activeVal == true || activeVal == '1';

    return GuruItem(
      id: j['id'] is int ? j['id'] as int : int.tryParse(j['id']?.toString() ?? ''),
      nama: namaVal,
      nipNuptk: nipNuptk,
      mapel: mapelVal,
      email: emailVal,
      telepon: telpVal,
      gender: genderVal,
      alamat: alamatVal,
      aktif: isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nama_lengkap': nama,
        'nama': nama,
        'nip': nipNuptk.isEmpty ? null : nipNuptk,
        'bidang_studi': mapel,
        'mapel': mapel,
        'email': email,
        'no_hp': telepon,
        'telepon': telepon,
        'gender': gender,
        'alamat': alamat,
        'is_active': aktif ? 1 : 0,
      };

  GuruItem copyWith({
    int? id,
    String? nama,
    String? nipNuptk,
    String? mapel,
    String? email,
    String? telepon,
    String? gender,
    String? alamat,
    bool? aktif,
  }) {
    return GuruItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nipNuptk: nipNuptk ?? this.nipNuptk,
      mapel: mapel ?? this.mapel,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      gender: gender ?? this.gender,
      alamat: alamat ?? this.alamat,
      aktif: aktif ?? this.aktif,
    );
  }
}

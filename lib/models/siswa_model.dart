class SiswaItem {
  final int? id;
  final String nama;
  final String nis;
  final String nisn;
  final int? kelasId;
  final String kelas;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String namaWali;
  final String noHpWali;
  final String alamat;
  final bool aktif;

  const SiswaItem({
    this.id,
    required this.nama,
    required this.kelas,
    this.nis = '',
    this.nisn = '',
    this.kelasId,
    this.jenisKelamin = 'Laki-laki',
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.namaWali = '',
    this.noHpWali = '',
    this.alamat = '',
    this.aktif = true,
  });

  factory SiswaItem.fromJson(Map<String, dynamic> j) {
    final namaVal = (j['nama_lengkap'] ?? j['nama'] ?? '').toString();
    final nisVal = (j['nis'] ?? '').toString();
    final nisnVal = (j['nisn'] ?? '').toString();
    final kelasVal = (j['kelas'] ?? j['nama_kelas'] ?? j['class_name'] ?? '').toString();

    final rawKelasId = j['kelas_id'] ?? j['class_id'];
    final kelasIdVal = rawKelasId is int ? rawKelasId : int.tryParse(rawKelasId?.toString() ?? '');

    final rawGender = (j['jenis_kelamin'] ?? j['gender'] ?? '').toString();
    String genderVal = 'Laki-laki';
    if (rawGender.toUpperCase() == 'P' || rawGender.toLowerCase().contains('perempuan')) {
      genderVal = 'Perempuan';
    }

    final tempatVal = (j['tempat_lahir'] ?? j['birth_place'] ?? '').toString();
    final tglVal = (j['tanggal_lahir'] ?? j['birth_date'] ?? '').toString();
    final waliVal = (j['nama_wali'] ?? j['guardian_name'] ?? '').toString();
    final noHpWaliVal = (j['no_hp_wali'] ?? j['guardian_phone'] ?? '').toString();
    final alamatVal = (j['alamat'] ?? j['address'] ?? '').toString();

    final activeVal = j['is_active'] ?? j['aktif'];
    final bool isActive = activeVal == 1 || activeVal == true || activeVal == '1' || activeVal == null;

    return SiswaItem(
      id: j['id'] is int ? j['id'] as int : int.tryParse(j['id']?.toString() ?? ''),
      nama: namaVal,
      nis: nisVal,
      nisn: nisnVal,
      kelasId: kelasIdVal,
      kelas: kelasVal,
      jenisKelamin: genderVal,
      tempatLahir: tempatVal,
      tanggalLahir: tglVal,
      namaWali: waliVal,
      noHpWali: noHpWaliVal,
      alamat: alamatVal,
      aktif: isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nama_lengkap': nama,
        'nama': nama,
        'nis': nis,
        'nisn': nisn,
        if (kelasId != null) 'kelas_id': kelasId,
        'kelas': kelas,
        'jenis_kelamin': jenisKelamin,
        'gender': jenisKelamin.toLowerCase().contains('perempuan') ? 'P' : 'L',
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'nama_wali': namaWali,
        'no_hp_wali': noHpWali,
        'alamat': alamat,
        'is_active': aktif ? 1 : 0,
      };

  SiswaItem copyWith({
    int? id,
    String? nama,
    String? nis,
    String? nisn,
    int? kelasId,
    String? kelas,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    String? namaWali,
    String? noHpWali,
    String? alamat,
    bool? aktif,
  }) {
    return SiswaItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      kelasId: kelasId ?? this.kelasId,
      kelas: kelas ?? this.kelas,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      namaWali: namaWali ?? this.namaWali,
      noHpWali: noHpWali ?? this.noHpWali,
      alamat: alamat ?? this.alamat,
      aktif: aktif ?? this.aktif,
    );
  }
}

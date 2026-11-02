import 'package:flutter/material.dart';

import '../../../models/presensi_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/presensi_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

enum _StatusCek { ok, peringatan, gagal }

class _ItemCek {
  final String label;
  final _StatusCek status;
  const _ItemCek(this.label, this.status);
}

class PresensiKonfirmasiPage extends StatefulWidget {
  final HasilLokasi lokasi;
  const PresensiKonfirmasiPage({super.key, required this.lokasi});

  @override
  State<PresensiKonfirmasiPage> createState() => _PresensiKonfirmasiPageState();
}

class _PresensiKonfirmasiPageState extends State<PresensiKonfirmasiPage> {
  static const Color _green = Color(0xFF219653);
  bool _menyimpan = false;

  String get _guru => AuthService.instance.currentTeacherName ?? 'Guru';

  Future<void> _simpan() async {
    setState(() => _menyimpan = true);
    final hasil =
        await PresensiService.instance.simpan(_guru, widget.lokasi);
    if (!mounted) return;
    setState(() => _menyimpan = false);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(hasil.pesan),
        backgroundColor: hasil.berhasil ? _green : Colors.red,
      ));

    if (hasil.berhasil) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = PresensiService.instance;
    final lokasi = widget.lokasi;
    final jenis = service.jenisScanBerikutnya(_guru);
    final status = service.statusJikaScanSekarang(_guru);
    final sisaJeda = service.sisaJeda(_guru);
    final lengkap = service.sudahLengkap(_guru);

    final cek = <_ItemCek>[
      _ItemCek('Berada di Lokasi',
          lokasi.valid ? _StatusCek.ok : _StatusCek.gagal),
      if (jenis == JenisScan.datang)
        _ItemCek(
          status == StatusPresensi.tepatWaktu ? 'Tepat Waktu' : 'Terlambat',
          status == StatusPresensi.tepatWaktu
              ? _StatusCek.ok
              : _StatusCek.peringatan,
        )
      else
        const _ItemCek('Sudah Presensi Datang', _StatusCek.ok),
      const _ItemCek('Data Sesuai', _StatusCek.ok),
    ];

    final bisaSimpan =
        lokasi.valid && !lengkap && sisaJeda == null && !_menyimpan;
    final labelTombol = jenis == JenisScan.datang
        ? 'Presensi Datang Sekarang'
        : 'Presensi Pulang Sekarang';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 16),
                    const SizedBox(width: 12),
                    Text('Presensi',
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _kartu(
                child: Text(_guru,
                    style: AppTextStyle.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              _kartuLokasi(lokasi),
              const SizedBox(height: 24),
              Text('Deskripsi',
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 15)),
              const SizedBox(height: 10),
              _kartu(
                child: Column(
                  children: cek.map(_barisCek).toList(),
                ),
              ),
              if (!lokasi.valid || sisaJeda != null || lengkap) ...[
                const SizedBox(height: 12),
                Text(
                  lengkap
                      ? 'Presensi hari ini sudah lengkap (datang dan pulang).'
                      : !lokasi.valid
                          ? lokasi.pesan
                          : 'Tunggu ${service.formatSisa(sisaJeda!)} sebelum presensi pulang.',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: bisaSimpan ? _simpan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(labelTombol,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartu({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33CDC9C5), blurRadius: 15, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _kartuLokasi(HasilLokasi lokasi) {
    final warna = lokasi.valid ? _green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(lokasi.valid ? Icons.location_on : Icons.location_off,
              size: 56, color: warna),
          const SizedBox(height: 10),
          Text(
            lokasi.jarakMeter != null
                ? 'Anda ${lokasi.jarakMeter!.round()} m dari titik sekolah'
                : 'Lokasi tidak terbaca',
            style: AppTextStyle.bodyMedium
                .copyWith(fontWeight: FontWeight.w600, color: warna),
          ),
          const SizedBox(height: 4),
          Text(
            lokasi.pesan,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _barisCek(_ItemCek item) {
    final (IconData ikon, Color warna) = switch (item.status) {
      _StatusCek.ok => (Icons.check_circle, _green),
      _StatusCek.peringatan => (Icons.error, Colors.orange),
      _StatusCek.gagal => (Icons.cancel, Colors.red),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(ikon, color: warna, size: 22),
          const SizedBox(width: 14),
          Text(item.label,
              style: AppTextStyle.bodyMedium
                  .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
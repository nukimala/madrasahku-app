import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../services/auth_service.dart';
import '../../../services/presensi_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'presensi_konfirmasi_page.dart';

class PresensiScanPage extends StatefulWidget {
  const PresensiScanPage({super.key});

  @override
  State<PresensiScanPage> createState() => _PresensiScanPageState();
}

class _PresensiScanPageState extends State<PresensiScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _memproses = false;

  @override
  void initState() {
    super.initState();
    PresensiService.instance.sinkronkanHariIni().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _proses(String? kode) async {
    if (_memproses) return;
    setState(() => _memproses = true);
    await _controller.stop();

    final service = PresensiService.instance;

    if (!service.validasiQr(kode)) {
      _pesan('QR tidak dikenali. Scan QR presensi di ruang guru.');
      await Future.delayed(const Duration(seconds: 1));
      await _lanjutScan();
      return;
    }

    final guru = AuthService.instance.currentTeacherName ?? 'Guru';

    if (service.sudahLengkap(guru)) {
      _pesan('Presensi hari ini sudah lengkap (datang dan pulang).');
      await Future.delayed(const Duration(seconds: 1));
      await _lanjutScan();
      return;
    }

    final sisa = service.sisaJeda(guru);
    if (sisa != null) {
      _pesan('Tunggu ${service.formatSisa(sisa)} sebelum presensi pulang.');
      await Future.delayed(const Duration(seconds: 1));
      await _lanjutScan();
      return;
    }

    final lokasi = await service.cekLokasi();
    if (!mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => PresensiKonfirmasiPage(lokasi: lokasi)),
    );

    // Kembali dari halaman konfirmasi tanpa menyimpan -> scan lagi.
    if (!mounted) return;
    await _lanjutScan();
  }

  Future<void> _lanjutScan() async {
    if (!mounted) return;
    await _controller.start();
    if (mounted) setState(() => _memproses = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 16),
                    const SizedBox(width: 12),
                    Text('Kembali',
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Arahkan kamera ke QR presensi di ruang guru',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: MobileScanner(
                            controller: _controller,
                            onDetect: (capture) {
                              final kode = capture.barcodes.isNotEmpty
                                  ? capture.barcodes.first.rawValue
                                  : null;
                              _proses(kode);
                            },
                            errorBuilder: (context, error) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Kamera tidak dapat dibuka. Periksa izin kamera.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF219653), width: 3),
                            ),
                          ),
                        ),
                        if (_memproses)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                        color: Colors.white),
                                    SizedBox(height: 12),
                                    Text('Memeriksa lokasi...',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tombol simulasi hanya muncul saat debug (emulator tanpa kamera).
              if (kDebugMode)
                TextButton.icon(
                  onPressed:
                      _memproses ? null : () => _proses(PresensiService.kodeQr),
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('Simulasi scan QR (debug)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
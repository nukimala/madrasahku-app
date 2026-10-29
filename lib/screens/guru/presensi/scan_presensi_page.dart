import 'package:flutter/material.dart';
import '../../../services/presensi_service.dart';
import '../../../utilis/app_colors.dart';

class ScanPresensiPage extends StatefulWidget {
  const ScanPresensiPage({super.key});

  @override
  State<ScanPresensiPage> createState() => _ScanPresensiPageState();
}

class _ScanPresensiPageState extends State<ScanPresensiPage>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF219653);

  bool _isScannerMode = true; // Toggle between Scanner & QR Display

  void _onScanSuccess() {
    PresensiService.instance.catatPresensi();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: _green, size: 28),
            SizedBox(width: 8),
            Text('Scan Berhasil!'),
          ],
        ),
        content: const Text(
          'QR Code Presensi berhasil diverifikasi. Kehadiran Anda telah dicatat ke sistem.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _isScannerMode ? 'Scan Presensi' : 'QR Presensi',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          label: const Text(
            'Kembali',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        leadingWidth: 110,
        actions: [
          IconButton(
            icon: Icon(
              _isScannerMode ? Icons.qr_code : Icons.qr_code_scanner,
              color: _green,
            ),
            tooltip: _isScannerMode ? 'Tampilkan QR Code' : 'Buka Scanner',
            onPressed: () => setState(() => _isScannerMode = !_isScannerMode),
          ),
        ],
      ),
      body: _isScannerMode ? _buildScannerView() : _buildQrDisplayView(),
    );
  }

  // View: Scanner (Scan Presensi-2.png)
  Widget _buildScannerView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Viewfinder Frame
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _ScannerBoxPainter(),
                  ),
                  // Center Scan Line
                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Green Button "Unggah File"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onScanSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Unggah File / Scan Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // View: QR Display (Scan Presensi-1.png)
  Widget _buildQrDisplayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Card 1: Pertemuan ke 1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Pertemuan ke 1',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Card 2: Mts Alhuda Gondang
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Mts Alhuda Gondang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Date time
          const Text(
            '14:00, 09 September 2026 – 15:02, 25 September 2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 28),

          // Big QR Code Representation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _QrCodePainter(),
            ),
          ),

          const SizedBox(height: 36),

          OutlinedButton.icon(
            onPressed: () => setState(() => _isScannerMode = true),
            icon: const Icon(Icons.qr_code_scanner, color: _green),
            label: const Text(
              'Buka Mode Kamera Scanner',
              style: TextStyle(color: _green, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const cornerLength = 55.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Outer corners
    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 50, 50), paint);
      canvas.drawRect(Rect.fromLTWH(x + 8, y + 8, 34, 34), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(x + 16, y + 16, 18, 18), paint);
    }

    drawFinder(0, 0);
    drawFinder(size.width - 50, 0);
    drawFinder(0, size.height - 50);

    // Some simulated QR blocks
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.2, 16, 16), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.55, size.height * 0.35, 20, 20), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.6, 22, 22), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.7, 18, 18), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.75, size.height * 0.5, 24, 16), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.25, size.height * 0.35, 14, 28), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

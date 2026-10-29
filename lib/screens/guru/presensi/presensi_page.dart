import 'package:flutter/material.dart';
import '../../../services/presensi_service.dart';
import '../../../utilis/app_colors.dart';
import 'scan_presensi_page.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  static const Color _green = Color(0xFF219653);

  bool _beradaDiLokasi = true;
  bool _tepatWaktu = true;
  bool _dataSesuai = true;
  bool _isSuccess = false;

  void _lakukanPresensi() {
    PresensiService.instance.catatPresensi();
    setState(() => _isSuccess = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: _green, size: 28),
            SizedBox(width: 8),
            Text('Presensi Berhasil'),
          ],
        ),
        content: const Text(
          'Presensi kehadiran Anda di MTs Al Huda Pandean Gondang telah tercatat secara otomatis.',
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
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _bukaScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanPresensiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Presensi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: _green),
            tooltip: 'Scan QR Presensi',
            onPressed: _bukaScanner,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lokasi Input Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Adam Knalpot · MTs Al Huda Pandean',
                  hintStyle: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.my_location, color: _green, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Map Card
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EED9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Road map representation
                  CustomPaint(
                    size: const Size(double.infinity, 280),
                    painter: _MapRoadPainter(),
                  ),

                  // Marker Sanamma Computer
                  Positioned(
                    top: 40,
                    left: 100,
                    child: _buildMapPin(
                      icon: Icons.shopping_bag,
                      iconColor: Colors.blue,
                      title: 'Sanamma Computer',
                      subtitle: 'Electronics store',
                    ),
                  ),

                  // Marker MTs Al Huda Pandean Gondang
                  Positioned(
                    top: 110,
                    left: 110,
                    child: _buildMapPin(
                      icon: Icons.school,
                      iconColor: const Color(0xFF4B5563),
                      title: 'MTs Al Huda',
                      subtitle: 'Pandean Gondang',
                      isMain: true,
                    ),
                  ),

                  // Marker Pawon20
                  Positioned(
                    bottom: 60,
                    left: 130,
                    child: Row(
                      children: [
                        const Text(
                          'Pawon20',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEA580C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restaurant, color: Colors.white, size: 12),
                        ),
                      ],
                    ),
                  ),

                  // Google Map data watermark
                  const Positioned(
                    bottom: 10,
                    left: 12,
                    child: Text(
                      'Google',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 10,
                    right: 12,
                    child: Text(
                      'Map data ©2026',
                      style: TextStyle(fontSize: 10, color: Color(0xFF5F6368)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Heading Deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            // Checklist Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCheckItem(
                    label: 'Berada di Lokasi',
                    value: _beradaDiLokasi,
                    onChanged: (v) => setState(() => _beradaDiLokasi = v ?? false),
                  ),
                  _buildCheckItem(
                    label: 'Tepat Waktu',
                    value: _tepatWaktu,
                    onChanged: (v) => setState(() => _tepatWaktu = v ?? false),
                  ),
                  _buildCheckItem(
                    label: 'Data Sesuai',
                    value: _dataSesuai,
                    onChanged: (v) => setState(() => _dataSesuai = v ?? false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Tombol Presensi Sekarang
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _lakukanPresensi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _isSuccess ? 'Presensi Tercatat ✓' : 'Presensi Sekarang',
                  style: const TextStyle(
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
      ),
    );
  }

  Widget _buildCheckItem({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF15803D) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? const Color(0xFF15803D) : const Color(0xFF9CA3AF),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isMain = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isMain ? 12 : 11,
                fontWeight: FontWeight.bold,
                color: isMain ? const Color(0xFF1F2937) : const Color(0xFF2563EB),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.42, 0);
    path.lineTo(size.width * 0.38, size.height * 0.5);
    path.lineTo(size.width * 0.85, size.height * 0.56);

    final path2 = Path();
    path2.moveTo(size.width * 0.55, size.height * 0.53);
    path2.lineTo(size.width * 0.53, size.height);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';

class RekapPresensiGuruPage extends StatefulWidget {
  const RekapPresensiGuruPage({super.key});

  @override
  State<RekapPresensiGuruPage> createState() => _RekapPresensiGuruPageState();
}

class _RekapPresensiGuruPageState extends State<RekapPresensiGuruPage> {
  static const Color _green = Color(0xFF219653);

  final _namaController = TextEditingController();
  String _selectedMapel = 'Matematika';

  final List<String> _mapelList = [
    'Matematika',
    'Al-Qur’an Hadis',
    'Akidah Akhlak',
    'Fikih',
    'Bahasa Indonesia',
    'Bahasa Arab',
    'IPA',
  ];

  @override
  void initState() {
    super.initState();
    _namaController.text = AuthService.instance.currentTeacherName ?? 'Siti Nurhaliza';
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rekap Presensi',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilih nama
            const Text(
              'Pilih nama',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            _buildInputContainer(
              child: TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama guru',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Pilih mapel yang diampu
            const Text(
              'Pilih mapel yang diampu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            _buildInputContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMapel,
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                  ),
                  items: _mapelList.map((m) => DropdownMenuItem(
                    value: m,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(m, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMapel = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Tampilkan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Menampilkan rekap presensi mapel $_selectedMapel')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: const Text(
                  'Tampilkan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4 Status Summary Cards
            Row(
              children: [
                _buildStatCard(title: 'Hadir', count: '245', bg: const Color(0xFFDCFCE7), textColor: const Color(0xFF15803D)),
                const SizedBox(width: 8),
                _buildStatCard(title: 'Izin', count: '12', bg: const Color(0xFFFFEDD5), textColor: const Color(0xFFC2410C)),
                const SizedBox(width: 8),
                _buildStatCard(title: 'Sakit', count: '8', bg: const Color(0xFFE0F2FE), textColor: const Color(0xFF0284C7)),
                const SizedBox(width: 8),
                _buildStatCard(title: 'Alpha', count: '5', bg: const Color(0xFFFFE4E6), textColor: const Color(0xFFE11D48)),
              ],
            ),

            const SizedBox(height: 28),

            // Heading Daftar Presensi
            const Text(
              'Daftar Presensi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 12),

            // Detail Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubjectRow('Matematika', hadir: 25, izin: 2, sakit: 1, alpha: 2),
                  const Divider(height: 24),
                  _buildSubjectRow('Bahasa Indonesia', hadir: 25, izin: 2, sakit: 1, alpha: 2),
                  const Divider(height: 24),
                  _buildSubjectRow('IPA', hadir: 25, izin: 2, sakit: 1, alpha: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRow(String subject, {required int hadir, required int izin, required int sakit, required int alpha}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Hadir: $hadir', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
            const SizedBox(width: 14),
            Text('Izin: $izin', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
            const SizedBox(width: 14),
            Text('Sakit: $sakit', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
            const SizedBox(width: 14),
            Text('Alpha: $alpha', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color bg,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
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
      child: child,
    );
  }
}

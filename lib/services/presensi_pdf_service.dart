import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RekapItemPdf {
  final String nama;
  final String mapel;
  final String kelas;
  final int hadir;
  final int pulang;

  const RekapItemPdf({
    required this.nama,
    required this.mapel,
    required this.kelas,
    required this.hadir,
    required this.pulang,
  });
}

class PresensiPdfService {
  static Future<void> exportPdf({
    required String periode,
    required String mapel,
    required String kelas,
    required List<RekapItemPdf> items,
  }) async {
    final doc = pw.Document();

    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final now = DateTime.now();
    final tglCetak = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    int totalHadir = 0;
    int totalPulang = 0;
    for (final item in items) {
      totalHadir += item.hadir;
      totalPulang += item.pulang;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'YAYASAN PENDIDIKAN AL-HUDA GONDANG',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'MADRASAH TSANAWIYAH AL-HUDA GONDANG',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
            ),
            pw.Text(
              'NSM: 121235180039 | NPSN: 20582234 | Akreditasi A',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'Jln. Letjen Soeprapto No.16 Ds. Pandean Kec. Gondang Kab. Nganjuk',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 2, color: PdfColors.black),
            pw.Divider(thickness: 0.5, color: PdfColors.black),
            pw.SizedBox(height: 12),
            pw.Text(
              'LAPORAN REKAPITULASI PRESENSI',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Periode: $periode', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('Mapel: $mapel', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('Kelas: $kelas', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('Dicetak: $tglCetak', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Sistem Informasi Akademik & Presensi Madrasahku',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['No', 'Nama Guru / Siswa', 'Mata Pelajaran', 'Kelas', 'Hadir', 'Pulang'],
            data: List.generate(items.length, (index) {
              final it = items[index];
              return [
                '${index + 1}',
                it.nama,
                it.mapel,
                it.kelas,
                '${it.hadir} kali',
                '${it.pulang} kali',
              ];
            }),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
            },
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          pw.SizedBox(height: 12),
          // Total Box
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Text('Total Entri: ${items.length}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Kehadiran: $totalHadir', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                pw.Text('Total Kepulangan: $totalPulang', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          // Tanda Tangan
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Kepala Madrasah', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 50),
                  pw.Text('M. ABDUL HARIS JAUHARI, S.Pd.I', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  pw.Text('NIP. -', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Nganjuk, ${now.day} ${_getNamaBulan(now.month)} ${now.year}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Admin / Operator Madrasah', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 50),
                  pw.Text('ADMIN MADRASAH', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  pw.Text('Staff Tata Usaha', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Rekap_Presensi_${periode.replaceAll(' ', '_')}.pdf',
    );
  }

  static String _getNamaBulan(int month) {
    const list = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return list[month - 1];
    return '';
  }
}

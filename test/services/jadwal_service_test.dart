import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasimadrasahku/models/jadwal_model.dart';
import 'package:aplikasimadrasahku/services/auth_service.dart';
import 'package:aplikasimadrasahku/services/jadwal_service.dart';

void main() {
  const schoolYear = '2098/2099';
  final service = JadwalService.instance;

  JadwalPelajaran schedule({
    int id = 0,
    String className = 'VII A',
    HariSekolah day = HariSekolah.senin,
    int start = 420,
    int end = 460,
    String teacher = 'Siti Nurhaliza',
    String room = 'Ruang 1',
  }) => JadwalPelajaran(
    id: id,
    tahunAjaran: schoolYear,
    semester: Semester.ganjil,
    kelas: className,
    hari: day,
    mulaiMenit: start,
    selesaiMenit: end,
    mataPelajaran: 'Matematika',
    guru: teacher,
    ruang: room,
  );

  test('rejects overlapping class, teacher, and room bookings', () {
    expect(service.simpan(schedule()), isNull);
    expect(
      service.simpan(schedule(start: 430, end: 470, teacher: 'Budi Santoso')),
      contains('Kelas VII A'),
    );
    expect(
      service.simpan(
        schedule(className: 'VII B', start: 430, end: 470, room: 'Ruang 2'),
      ),
      contains('Siti Nurhaliza'),
    );
    expect(
      service.simpan(
        schedule(
          className: 'VII C',
          start: 430,
          end: 470,
          teacher: 'Budi Santoso',
        ),
      ),
      contains('Ruang 1'),
    );
    expect(
      service.simpan(
        schedule(className: 'VII B', start: 460, end: 500, room: 'Ruang 1'),
      ),
      isNull,
    );
    expect(service.simpan(schedule(start: 500, end: 490)), isNotNull);
  });

  test('copies a day while skipping conflicting target slots', () {
    service.simpan(
      schedule(
        className: 'VIII A',
        day: HariSekolah.rabu,
        start: 420,
        end: 460,
        teacher: 'Ahmad Fauzi',
        room: 'Ruang 3',
      ),
    );
    service.simpan(
      schedule(
        className: 'VIII A',
        day: HariSekolah.rabu,
        start: 460,
        end: 500,
        teacher: 'Budi Santoso',
        room: 'Ruang 4',
      ),
    );
    service.simpan(
      schedule(
        className: 'VIII B',
        day: HariSekolah.kamis,
        start: 420,
        end: 460,
        teacher: 'Nur Aini',
        room: 'Ruang 3',
      ),
    );

    final result = service.salinHari(
      tahunAjaran: schoolYear,
      semester: Semester.ganjil,
      kelas: 'VIII A',
      dariHari: HariSekolah.rabu,
      keHari: HariSekolah.kamis,
    );

    expect(result.tersalin, 1);
    expect(result.dilewati, 1);
    expect(
      service.jadwalKelas(
        tahunAjaran: schoolYear,
        semester: Semester.ganjil,
        kelas: 'VIII A',
        hari: HariSekolah.kamis,
      ),
      hasLength(1),
    );
  });

  test(
    'teacher demo account reads only schedules assigned to its identity',
    () {
      service.simpan(
        schedule(
          className: 'IX A',
          day: HariSekolah.sabtu,
          start: 480,
          end: 520,
          teacher: 'Siti Nurhaliza',
          room: 'Ruang 5',
        ),
      );
      service.simpan(
        schedule(
          className: 'IX B',
          day: HariSekolah.sabtu,
          start: 480,
          end: 520,
          teacher: 'Ahmad Fauzi',
          room: 'Ruang 4',
        ),
      );

      final auth = AuthService.instance;
      auth.startDemoSession('guru');
      final teacherSchedules = service.jadwalGuru(
        tahunAjaran: schoolYear,
        semester: Semester.ganjil,
        guru: auth.currentTeacherName!,
        hari: HariSekolah.sabtu,
      );

      expect(auth.currentTeacherName, 'Siti Nurhaliza');
      expect(teacherSchedules, hasLength(1));
      expect(teacherSchedules.single.kelas, 'IX A');
      auth.logout();
    },
  );
}

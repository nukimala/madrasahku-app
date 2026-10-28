import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasimadrasahku/models/admin_profile_model.dart';
import 'package:aplikasimadrasahku/services/auth_service.dart';

void main() {
  test('admin profile and credentials update the demo login session', () {
    final auth = AuthService.instance;
    auth.logout();

    expect(auth.login('admin@madrasahku.sch.id', 'admin123'), isTrue);
    expect(auth.currentRole, 'admin');

    final updatedProfile = AdminProfile(
      namaLengkap: 'Admin Madrasah Baru',
      email: 'admin.baru@madrasahku.sch.id',
      username: 'admin_baru',
      nomorTelepon: '081234567890',
    );
    expect(auth.updateAdminProfile(updatedProfile), isTrue);
    expect(auth.adminProfile.namaLengkap, updatedProfile.namaLengkap);
    expect(auth.adminProfile.email, updatedProfile.email);
    expect(auth.adminProfile.username, updatedProfile.username);
    expect(auth.adminProfile.nomorTelepon, updatedProfile.nomorTelepon);

    expect(
      auth.updateAdminProfile(
        AdminProfile(
          namaLengkap: 'Duplikat',
          email: 'guru@madrasahku.sch.id',
          username: 'admin_lain',
          nomorTelepon: '081234567890',
        ),
      ),
      isFalse,
    );
    expect(
      auth.changeAdminPassword(
        currentPassword: 'salah',
        newPassword: 'passwordBaru123',
      ),
      isFalse,
    );
    expect(
      auth.changeAdminPassword(
        currentPassword: 'admin123',
        newPassword: 'passwordBaru123',
      ),
      isTrue,
    );

    auth.logout();
    expect(auth.currentRole, isNull);
    expect(auth.login('admin@madrasahku.sch.id', 'admin123'), isFalse);
    expect(auth.login('admin_baru', 'passwordBaru123'), isTrue);
    expect(auth.currentRole, 'admin');
    auth.logout();
  });
}

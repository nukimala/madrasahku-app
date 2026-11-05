-- ========================================================
-- DATABASE SYSTEM: APLIKASI MADRASAHKU (MTs AL-HUDA)
-- ========================================================

CREATE DATABASE IF NOT EXISTS `madrasahku_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `madrasahku_db`;

-- Hapus tabel lama (urutan dibalik karena foreign key) supaya file ini bisa diimpor ulang
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `assignment_submissions`, `assignments`, `materials`, `teacher_attendances`,
  `school_locations`, `schedules`, `subjects`, `siswas`, `classes`, `gurus`, `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------
-- 1. TABEL PENGGUNA & AUTENTIKASI (users)
-- --------------------------------------------------------
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('admin', 'guru', 'siswa') NOT NULL DEFAULT 'siswa',
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 2. TABEL DATA GURU (gurus)
-- --------------------------------------------------------
CREATE TABLE `gurus` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL UNIQUE,
  `nip` VARCHAR(30) NULL UNIQUE,
  `nama_lengkap` VARCHAR(100) NOT NULL,
  `jenis_kelamin` ENUM('L', 'P') NOT NULL DEFAULT 'L',
  `no_hp` VARCHAR(20) NULL,
  `alamat` TEXT NULL,
  `foto_url` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_gurus_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 3. TABEL DATA KELAS (classes)
-- --------------------------------------------------------
CREATE TABLE `classes` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `nama_kelas` VARCHAR(20) NOT NULL UNIQUE, -- Contoh: VII A, VII B, VIII A
  `tingkat` ENUM('7', '8', '9') NOT NULL,
  `wali_kelas_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_classes_wali` FOREIGN KEY (`wali_kelas_id`) REFERENCES `gurus` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 4. TABEL DATA SISWA (siswas)
-- --------------------------------------------------------
CREATE TABLE `siswas` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL UNIQUE,
  `kelas_id` BIGINT UNSIGNED NOT NULL,
  `nisn` VARCHAR(20) NOT NULL UNIQUE,
  `nama_lengkap` VARCHAR(100) NOT NULL,
  `jenis_kelamin` ENUM('L', 'P') NOT NULL DEFAULT 'L',
  `alamat` TEXT NULL,
  `nama_wali` VARCHAR(100) NULL,
  `foto_url` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_siswas_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_siswas_kelas` FOREIGN KEY (`kelas_id`) REFERENCES `classes` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 5. TABEL MATA PELAJARAN (subjects)
-- --------------------------------------------------------
CREATE TABLE `subjects` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `kode_mapel` VARCHAR(20) NOT NULL UNIQUE, -- Contoh: MTK, ARB, QH
  `nama_mapel` VARCHAR(100) NOT NULL,       -- Contoh: Matematika, Bahasa Arab
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 6. TABEL JADWAL PELAJARAN (schedules)
-- --------------------------------------------------------
CREATE TABLE `schedules` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `kelas_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `guru_id` BIGINT UNSIGNED NOT NULL,
  `hari` ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu') NOT NULL,
  `jam_mulai` TIME NOT NULL,
  `jam_selesai` TIME NOT NULL,
  `ruangan` VARCHAR(50) DEFAULT 'Ruang Kelas',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_schedules_kelas` FOREIGN KEY (`kelas_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_schedules_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_schedules_guru` FOREIGN KEY (`guru_id`) REFERENCES `gurus` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 7. TABEL TITIK PRESENSI & QR KANTOR (school_locations)
-- --------------------------------------------------------
-- Untuk validasi barcode statis kantor + radius geofencing 10 meter
CREATE TABLE `school_locations` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `nama_lokasi` VARCHAR(100) NOT NULL DEFAULT 'Kantor Guru MTs Al-Huda',
  `qr_token` VARCHAR(100) NOT NULL UNIQUE, -- Isi teks di dalam QR statis yang dicetak
  `latitude` DECIMAL(10, 8) NOT NULL,      -- Titik koordinat GPS kantor
  `longitude` DECIMAL(11, 8) NOT NULL,
  `radius_meter` INT UNSIGNED NOT NULL DEFAULT 10, -- Batas radius 10 meter
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 8. TABEL PRESENSI GURU (teacher_attendances)
-- --------------------------------------------------------
CREATE TABLE `teacher_attendances` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `guru_id` BIGINT UNSIGNED NOT NULL,
  `tanggal` DATE NOT NULL,
  `jam_masuk` TIME NULL,
  `jam_pulang` TIME NULL,
  `lat_masuk` DECIMAL(10, 8) NULL,
  `long_masuk` DECIMAL(11, 8) NULL,
  `lat_pulang` DECIMAL(10, 8) NULL,
  `long_pulang` DECIMAL(11, 8) NULL,
  `status` ENUM('hadir', 'terlambat', 'izin', 'sakit', 'alpa') NOT NULL DEFAULT 'hadir',
  `keterangan` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_guru_tanggal` (`guru_id`, `tanggal`),
  CONSTRAINT `fk_attendance_guru` FOREIGN KEY (`guru_id`) REFERENCES `gurus` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 9. TABEL MATERI PEMBELAJARAN (materials)
-- --------------------------------------------------------
CREATE TABLE `materials` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `guru_id` BIGINT UNSIGNED NOT NULL,
  `kelas_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `judul` VARCHAR(150) NOT NULL,
  `deskripsi` TEXT NULL,
  `file_url` VARCHAR(255) NULL, -- URL file materi (PDF/PPT/DOCX)
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_materials_guru` FOREIGN KEY (`guru_id`) REFERENCES `gurus` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_materials_kelas` FOREIGN KEY (`kelas_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_materials_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 10. TABEL TUGAS PEMBELAJARAN (assignments)
-- --------------------------------------------------------
CREATE TABLE `assignments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `guru_id` BIGINT UNSIGNED NOT NULL,
  `kelas_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `judul` VARCHAR(150) NOT NULL,
  `instruksi` TEXT NOT NULL,
  `file_tugas_url` VARCHAR(255) NULL, -- Lampiran soal dari guru (opsional)
  `deadline` DATETIME NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_assignments_guru` FOREIGN KEY (`guru_id`) REFERENCES `gurus` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignments_kelas` FOREIGN KEY (`kelas_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignments_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- 11. TABEL PENGUMPULAN TUGAS SISWA (assignment_submissions)
-- --------------------------------------------------------
-- Khusus pemantauan pengumpulan tugas (tanpa penilaian angka)
CREATE TABLE `assignment_submissions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `assignment_id` BIGINT UNSIGNED NOT NULL,
  `siswa_id` BIGINT UNSIGNED NOT NULL,
  `file_jawaban_url` VARCHAR(255) NOT NULL, -- Berkas upload tugas siswa
  `catatan_siswa` TEXT NULL,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('submitted', 'late') NOT NULL DEFAULT 'submitted',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_submission` (`assignment_id`, `siswa_id`),
  CONSTRAINT `fk_submissions_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_submissions_siswa` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ========================================================
-- DATA AWAL (urutan: users -> gurus -> classes -> siswas)
-- Username guru & siswa dari nama (2 kata pertama, huruf kecil)
-- Password tiap akun: <username>123  (sebaiknya diganti)
-- ========================================================
START TRANSACTION;

-- A. USERS GURU (26 akun)
INSERT INTO `users` (`username`, `email`, `password`, `role`, `is_active`) VALUES
('said', NULL, '$2y$10$3hLo62ygUBcg/C51cdMRBeAwIFFYeOkBorTAYzDrr0bi3Vut75uBq', 'guru', 1),
('sarmin', NULL, '$2y$10$s.MbK2c8SNAUtRK5gmtlj..qRBJL60D/nTlh7khyHYw77Su92nRue', 'guru', 1),
('musthofa', NULL, '$2y$10$1E9nMw63eJERAhCoPYUTV.ZtTbP1CvBSLQjL55drfly3JHBio8BO.', 'guru', 1),
('farid.kurniawan', NULL, '$2y$10$0wmUOwG6jxCMasR8yB4hz.CMfbe/QjvDs9NDlHm1nRE3hnj3P6eZ.', 'guru', 1),
('subiyatin', NULL, '$2y$10$qbEFBmgeJaWNxeRIXLSPQ.mVN1/VKLIiGW/FBQ8w0KAp5tLT3f0zi', 'guru', 1),
('lilik.rahmawati', NULL, '$2y$10$oV8fMUhhwshZgKUPuB7PLuqQc9naOiNxkMld0YxaIzCN6KDf6dZu6', 'guru', 1),
('agus.setiawan', NULL, '$2y$10$mbYBe/M6uc6OA4T6.1xJIuim7nmpMHzqw7e2mGv.6vqMdTPHPRUNq', 'guru', 1),
('setyo.jatmiko', NULL, '$2y$10$.twW33cT4bsw7x5El4AZfudEjN7.bPLZJiv7bmsluiZ1pupP97B9a', 'guru', 1),
('sodikin.muslimin', NULL, '$2y$10$jmBo1Epqv2wrkoDkWgoRcuGVxOssUv8An5Q999g448FSh73VIDEF.', 'guru', 1),
('ulfatul.khumaydah', NULL, '$2y$10$yhCJx9LCnoGxjJzSyoKvsOK1IOerLgFwiYZ7undhRirBzpvW.7LUa', 'guru', 1),
('siti.amiroh', NULL, '$2y$10$NkpGqQbxICm/Y3pe1jSVvO6DYZhjxUok.T1Fy2gKzyPWm9B.Ae0xq', 'guru', 1),
('agus.budi', NULL, '$2y$10$OveHd0eJC.IVFSvSF2dh9Oo7PDNphfddL3OyXXUJZdOKK/Xz5SIb.', 'guru', 1),
('abdul.haris', NULL, '$2y$10$ItfZNeX4awHA4pcKnXGe4eSf3M7RUYMGAunGrZVmYFOWMvsSEluB.', 'guru', 1),
('siti.munfarida', NULL, '$2y$10$35DRgH/RocuZMLyX5jbH0u1PXVLm4Cgr3DNTrHWrdxbe52fmswoBy', 'guru', 1),
('faridatun.nimah', NULL, '$2y$10$MRmgia5rkP.os2/x35MzZuRG8EAO1tKph5u9HhRQzy6n9tPc50sTK', 'guru', 1),
('intan.rosiana', NULL, '$2y$10$uqTuCqk2rgklrDKSHVvxWuVT9idxvg9NV4S4cS3msa31BG06qyZbq', 'guru', 1),
('octavia.utswatun', NULL, '$2y$10$j0YzS4lszkESSywC7KpuS.BYQMdqit71mFlvqnBdBh7cfxEDDA2qe', 'guru', 1),
('nurul.chofifah', NULL, '$2y$10$WBwM.DfXRtmuNcUBmdmXCO9oR2rfPEnXpJYUb8n0foZHe00b5o8aW', 'guru', 1),
('syaban.wulana', NULL, '$2y$10$09/vG2hkliQgQ2vWaocB.eHi0eACU3mq9O2l9/yO5zbNW1qq2SrFi', 'guru', 1),
('winda.triyana', NULL, '$2y$10$u8jMbz6Be3MYqD4pNSC9xuvqxVGaccS.qEorUpNwhBL5/NEjGdmi.', 'guru', 1),
('nopi.purwanti', NULL, '$2y$10$skYegxx1nG6A6ASz1GAt9eXYUlBQ/pxD/vrpHms.hwnXetyde8.TW', 'guru', 1),
('kumala.azizatul', NULL, '$2y$10$4yIHY3lNqyWR5wA9rUkY4eWP1/Xyili.96qh3gaywlKLo3/mif5.m', 'guru', 1),
('titik.yuliati', NULL, '$2y$10$X3mz.U7rHTjGAryEwAfMQumeI7G7njUYrCKCMZNykbJSsKhVvAzkK', 'guru', 1),
('nur.fuad', NULL, '$2y$10$Fhmm2R23YCJkG/UjSu8oNeAMSd9ljwyjXkinRr5wQp.R92VRpoknq', 'guru', 1),
('sulijadi', NULL, '$2y$10$ZC2qHwgLspZirqNIAcOnieP5Gg2V4nohEkQuzgav0P2Tr9BsG/ZC2', 'guru', 1),
('alita.dian', NULL, '$2y$10$2Y8IJS2lm5u7LgPRAzIhS.yoHtfplQn1lfED.3FhUpxEqRouHTSsi', 'guru', 1);

-- B. USERS SISWA (63 akun)
INSERT INTO `users` (`username`, `email`, `password`, `role`, `is_active`) VALUES
('ahmad.faiz', NULL, '$2y$10$ZNbZZl8nI3ThEE/O4lggWufLzbyfdwITNWLoxqLYZMyzed6M3dtz2', 'siswa', 1),
('ahmad.jazuli', NULL, '$2y$10$IP3Rysbf9lpNNTvYf4ckj.0XbZHN3FYiF.2/gWFCZSqOP/P0jwzh.', 'siswa', 1),
('ahmadil.fuad', NULL, '$2y$10$6Q5v0aR2CF4lFce77BP/.e/lN7ToY9ZM35XG.cF7f0AQWiAJ.3z6G', 'siswa', 1),
('allfin.aditya', NULL, '$2y$10$B9wdT3Nw..I4QDEcS8P2NOKE0Dc7Ay703W52WeN90D5WgHGhJy6z2', 'siswa', 1),
('amanda.felicia', NULL, '$2y$10$dHyEXmT/H1WtsJdrYe/ikeMAVoKF/SLjEEG1kt2TeaAAUBjLSbuUm', 'siswa', 1),
('destin.natalia', NULL, '$2y$10$r07z4qnGqQYi3iIg1kvYkeFAKOtRZlbdVsD9uFCL8qX5qAeq8SINa', 'siswa', 1),
('dwi.saputra', NULL, '$2y$10$HCzd5rJJMjWnjTPoQnhLUu2LNn2HvdH9KEkK7H4YDlMhFdsgteQn.', 'siswa', 1),
('faiz.maulana', NULL, '$2y$10$KkydFwjgDa/wvQZkzS457.abWRRE06D6shU9p37T9LgUBtF47PqWu', 'siswa', 1),
('fawwas.salman', NULL, '$2y$10$lkIeK.GAnB/oqFy.8NCeqO0fs0IbxP2a525M56ENLJ9E3xvHRn35W', 'siswa', 1),
('jelita.anastasya', NULL, '$2y$10$G1dsPscW5YHqwDZLBEdKUO2QWd/UZ3Wrf3Q9AEugUOIslmYSoS1N6', 'siswa', 1),
('julia.rahmahwati', NULL, '$2y$10$EVX2XfqFW52oxEEDVHLQseihc0hsNoWV..8Fu1gePEhLII1HF/zmG', 'siswa', 1),
('kheshia.mey', NULL, '$2y$10$2ayOPSZLPUNmescCgSoBsunLvgAzStVQsgvqmZ6VNM3d.uTe8uGu2', 'siswa', 1),
('luky.afnan', NULL, '$2y$10$Pd.Ysmb7NkzonoOY5D5bXe/ZMHKiTIrhz.83ZVafiFSE2ssv1b0SC', 'siswa', 1),
('muhammad.aris', NULL, '$2y$10$GupmLCBt2sNx6FjBdt0elOPFbH4x3pICkis6itmoiYqRqQ38j/njq', 'siswa', 1),
('naafil.mubarokah', NULL, '$2y$10$dPCTKYCSJScLkrHSuw.40elbBmCf/Ebcz/aBkKJrFfG6NNojkguLS', 'siswa', 1),
('moh.fazda', NULL, '$2y$10$bo67K2etBY4XGXNjqagZKe/HTgrTu3DH9A7lB2nRgbtCTBcqQ6Rv2', 'siswa', 1),
('chayra.fayolla', NULL, '$2y$10$.dxZiB.NfwifOHin9iuG4.h2DlJCZngjL2jLtwT5/9eI2AJ8Rn0vW', 'siswa', 1),
('ferendra.yubi', NULL, '$2y$10$V41OsY.uW743TLFvSKERn.uwKdIjA4infYUDjj8WFwuzkj7pbgcae', 'siswa', 1),
('nabila.permatasari', NULL, '$2y$10$4A35S0qL2lWJ.Qqm53C4VeIPLj.1jaVdYBiJzJtyxkw0ry0hCDV6G', 'siswa', 1),
('septia.lila', NULL, '$2y$10$vC27XtwuQk/rZ2H3y6Fa8.9e03RV02j3zLrjBpeJElrqXI9AeuVr2', 'siswa', 1),
('sindi.candra', NULL, '$2y$10$c1CvH1bQpTkySScttzc/2evvgjptxKsMD56Myqz/NhRB2q2pJSbSa', 'siswa', 1),
('hafiz.kenzie', NULL, '$2y$10$geJ42tHneSpWhPKRaUs6.uzcgU7OdWSZbSRKZFPwTaze9h9BGLSqm', 'siswa', 1),
('mariska.avril', NULL, '$2y$10$b9MG2RX8XYtFRK7WOSJWo.oD0iDY6zKuGwQiKZS6byaHpx.Y2bDNO', 'siswa', 1),
('muhammad.jayson', NULL, '$2y$10$LOOc/omSKHTxTp6icGRuSOkKWL3/d8UnLoF3JF0Itg83kephihZ3e', 'siswa', 1),
('novelia.qorry', NULL, '$2y$10$3J0k1GHCbfUbi2KdG0s8eu0Qh7y9c5/SYQek//dqJR1LAZy8BTXDe', 'siswa', 1),
('qurrotun.ainin', NULL, '$2y$10$mtwpTrKUu7RSw2NAxpwX5OBSr2VnRW2Hq.7jAHqOn6MM/RWEOVlOy', 'siswa', 1),
('rehan.maulana', NULL, '$2y$10$i/RWA6yDR4wwkAFN8G6lKOPmOce20iJqqZkwr8CKQFS9YOIf9CRpq', 'siswa', 1),
('yuliana.dwi', NULL, '$2y$10$QhNI8DblL5d/JWKlW03TAeWj7zCLrabYcVh0WrbAsnKcxv5/cCMq2', 'siswa', 1),
('afrian.angga', NULL, '$2y$10$Nns1kFNKxrSHejT4tnsxu.egWv0DpUdFuraregFN7pZaFdC1BBWRy', 'siswa', 1),
('agiel.putra', NULL, '$2y$10$.Va.GSTViIzj7DKtjFtSR.FHahBSPxyVsuPRR2nQMH/fN11UnXnv6', 'siswa', 1),
('alfina.kholifah', NULL, '$2y$10$Pm.qlCjuObWbhokn0KRuI.Mqb6UzG3.3Pabe80pAOgh5fQj9fUikC', 'siswa', 1),
('alica.zahra', NULL, '$2y$10$Jgm1Zwe9AAV/9wWyyi2orOF09v5KWIfgStlZ2uHi0TYhxBp3mPaQu', 'siswa', 1),
('annissa.dwi', NULL, '$2y$10$N2WTOdnJm9uGgI77I/8aGernQhc.V38s65ajoZaa/CajbDJTY.8A2', 'siswa', 1),
('daryl.aydine', NULL, '$2y$10$De88W73Od6K20jhIcsxI6.OkuwDe8h/7XXXYrfGIfknbwCtHYuwHe', 'siswa', 1),
('dimas.yongky', NULL, '$2y$10$EKa6hBqKaUSvBGCUwexYXeIE7CjVqHZQEMDIwass1TGqWpFdpyl0.', 'siswa', 1),
('farrel.razqa', NULL, '$2y$10$6aHK0GaDg.blMnGCQNuBuu/bxw0DDvTrgkhQsF7GhLkRv5sw6XTtS', 'siswa', 1),
('kiara.laksita', NULL, '$2y$10$dNqABiAShdpWthjBQ2mINO6nRygqNsVqPfFJ5k2hGcvbZGaaOZw8e', 'siswa', 1),
('azhyfa.almedina', NULL, '$2y$10$t/LkYlFs4hkXLFSUwoaDGu0HfYy3GyYGng.8T6UbL0Wk2kpJuGIbq', 'siswa', 1),
('mohamad.rizqi', NULL, '$2y$10$f.u5wQXHlNjdTVkzWcauTuwnL5RuNMtg5AjIXwt2rnpgdf9TFyR1u', 'siswa', 1),
('muchammad.rizqi', NULL, '$2y$10$UZaWGrHw9ZqW/oyn8QfLI.UU4IoI7AmUwgiLIJYwDIS7rzNGvowEq', 'siswa', 1),
('muhammad.eko', NULL, '$2y$10$OGevBt0UzuIUfdByzTAFJeI5Z5Ls1GLfPbnPPngerEziflvPqZnJC', 'siswa', 1),
('muhammad.safii', NULL, '$2y$10$1FSKMK9qlD/SKEy6V9xH/uzIvEdBRIX1KYa9fu2M0oXLcCY7/kp5q', 'siswa', 1),
('halida.dwi', NULL, '$2y$10$cZt6Yjlyq3BoxjXcXRqqq.z8hJcL7rZt.SikLJy38AhFj14rUrTfa', 'siswa', 1),
('lukman.affan', NULL, '$2y$10$4rn1rW9N/WpJNBCZEqdBW.P3qVg2BtmIBNAuzF3NgJROT8qPSFVGm', 'siswa', 1),
('muhammad.han', NULL, '$2y$10$GNaNkO45ZyigfcRtdS7RT.pIF47PZHRVrHnCjicMQakWpAJ/57sGS', 'siswa', 1),
('muhammad.rizal', NULL, '$2y$10$cV.NKtZVrptq6QYfVx32v.HMG.SC4ahOHUUjbVtSKyLL1Q1oByAtG', 'siswa', 1),
('nur.syafa', NULL, '$2y$10$puOyTgofmBWDRq8DSYbure4dgbE8UDfUihOxhg8pJjUL1s8fymxfG', 'siswa', 1),
('putra.prasetyo', NULL, '$2y$10$pl.EjwAIEBOAMAuttLz2SO58/UeXTxs4utQgbG4pb8VsCGZST5JF.', 'siswa', 1),
('wisnutama.syahdhan', NULL, '$2y$10$7Ut1pqaGdxXTeVkTgHf9POwK4syAcE.w7VlwZfBzOfJBKL9NwhlRC', 'siswa', 1),
('wiwik.binti', NULL, '$2y$10$dE.6.byZY4qD32kQdXaW8.11IrHW9elC5nzGGmS9/ibbTbxMpaKY6', 'siswa', 1),
('yeni.afissunani', NULL, '$2y$10$yWej8Dft3cjlwY3sZ/m8lu/Qp//9FQLyGQukJVY1l8.3roWNUQH/G', 'siswa', 1),
('kaisan.gree', NULL, '$2y$10$fOnw4EIR3ZbrAmc7ZQp7SOc1KfC2bs9C4EeaRIZByr6v4DZxA3dVe', 'siswa', 1),
('mezzaluna.arsesha', NULL, '$2y$10$TYjjJd6tqcOV54O5xP1xaO38u39gzYx0pUWPztsroA1/28t.a4kiW', 'siswa', 1),
('moch.al', NULL, '$2y$10$YvdF1KI8Zj.m1fALY7ftaedZQj89uGXSM8cK7t53Sxqa1D0zT2Iuq', 'siswa', 1),
('mardiansyah.adi', NULL, '$2y$10$AJmckdRzsCBXECmpcs4RAePHF.Dw9uml735V.s0E0kBVko43Bin32', 'siswa', 1),
('andhi.putra', NULL, '$2y$10$m8YgxYPMQ5L/3a3C113XO.S01WOXvNgYowm1D7pIr/eyQkUBehTe.', 'siswa', 1),
('andhika.putra', NULL, '$2y$10$NHAswMrzRQW.HFft3/er8eF5b3BD9TrJs9IMpHqRlvYc8InrhMXke', 'siswa', 1),
('verra.ananda', NULL, '$2y$10$w5XLPd4mU8BCDp0QI9IQs.c5JjIZ/RcLtnSEeP6P6cwN/8oW8/hoS', 'siswa', 1),
('vickha.dwi', NULL, '$2y$10$9uJwv5GfTZWm.n7GQf6rwOAG307vpGFqDK59//nQEBS3La14FuSRK', 'siswa', 1),
('johan.rizki', NULL, '$2y$10$G6cIre8IsyD6dndbzjkIvuxgl5Y431XWIyyYmLlv5rsvzucWbHPD.', 'siswa', 1),
('mohamad.farel', NULL, '$2y$10$NvVhV0Plw.WLhMB3y8N0m.ARKArC.1VVrikvb9.el51wKoeG6ywJa', 'siswa', 1),
('mohammad.arfi', NULL, '$2y$10$gSVeuQVrfcr4k2J6Hck9m.lpnCcIDQHwxJlvwuhaYsFiV4qp19cGK', 'siswa', 1),
('mohhamad.andika', NULL, '$2y$10$dc0gmdvMHtYyuuOndQSOuue35AUBaAtRxx.Tr/TKeEO648R7Fjp.W', 'siswa', 1);

-- C. DATA GURU
INSERT INTO `gurus` (`user_id`, `nip`, `nama_lengkap`, `jenis_kelamin`, `no_hp`, `alamat`, `foto_url`) VALUES
((SELECT `id` FROM `users` WHERE `username` = 'said'), '0838743647200032', 'Drs. Said', 'L', NULL, 'Toko Pojok, RT. 004 RW. 002 Pandean, Gondang, Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'sarmin'), '3439745645200003', 'Drs. Sarmin', 'L', NULL, 'RT 01 RW 02 DS. JINTEL KEC. REJOSO KAB. NGANJUK', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'musthofa'), '6553757659200012', 'Mohammad Musthofa, S.Pd.I', 'L', NULL, 'Jl. Soeprapto 24 RT. 004 RW. 002 Pandean, Gondang, Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'farid.kurniawan'), '0456757659200023', 'Farid Kurniawan Novianto, SH', 'L', NULL, 'RT/RW 02/02 Dsn Sambong Desa Campur Kecamatan Gondang Kabupaten Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'subiyatin'), '7146757658300023', 'Subiyatin, S.Si', 'P', NULL, 'RT/RW 02/02 Dsn Sambong Desa Campur Kecamatan Gondang Kabupaten Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'lilik.rahmawati'), '5062760661210093', 'Lilik Rahmawati, S.Pd', 'P', NULL, 'SAMBONG RT.002 RW.005 DESA CAMPUR KECAMATAN GONDANG KABUPATEN NGANJUK', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'agus.setiawan'), '1354760667200003', 'Agus Setiawan, S.Pd', 'L', NULL, 'RT/RW :002/001, Dsn.Sawahan, Ds. Balonggebang, Kec.Gondang, Kab. Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'setyo.jatmiko'), '9261760662200023', 'Setyo Jatmiko, S.Pd', 'L', NULL, 'RT/RW 001/002 Desa Karang Tengah Kecamatan Bagor Kab Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'sodikin.muslimin'), '6050763666200003', 'Sodikin Muslimin, S.Pd', 'L', NULL, 'Jln. Mojo Rt 09, Rw 02. Ds Gondangkulon, Kec Gondang', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'ulfatul.khumaydah'), '6852761662300052', 'Ulfatul Khumaydah, S.H.I', 'P', NULL, 'UTARA MASJID KAWEDEGAN DSN. KAWEDEGAN DS. BALONGGEBANG KEC. GONDANG KAB. NGANJUK JATIM 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'siti.amiroh'), '4561760661300033', 'Siti Amiroh, S.Pd.I', 'P', NULL, 'Dsn. Sambirejo RT 005 RW.005 DS. Katerban Kec.Baron Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'agus.budi'), '8145755658110013', 'Agus Budi Irawan, S.Pd.', 'L', NULL, 'RT 01 RW 01 Campur Gondang Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'abdul.haris'), '20537588191001', 'Muhammad Abdul Haris Jauhari, S.Pd.I', 'L', NULL, 'Haris Phonecell, Utara MTs Al-Huda Desa Pandean RT 04/RW 02, Kec. Gondang, Kab. Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'siti.munfarida'), '20537588188001', 'Siti Munfarida, S.Pd.I', 'P', NULL, 'Dsn. Pulo Rt. 004/ Rw. 006 Ds. Campur Kec. Gondang Kab. Nganjuk Kode pos 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'faridatun.nimah'), '20537588190003', 'Faridatun Ni`mah, S.Pd.I', 'P', NULL, 'Haris Phonecell, Utara MTs Al-Huda Desa Pandean RT 04/RW 02, Kec. Gondang, Kab. Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'intan.rosiana'), '20537588190002', 'Intan Rosiana Devi, S.Pd.', 'P', NULL, 'DESA NGUJUNG RT.01 / RW.01, Kel. Ngujung, Kec. Gondang Kab. Nganjuk, Prov. Jawa Timur KODE POS 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'octavia.utswatun'), '20537588197001', 'Octavia Utswatun Khasanah, S.Pd', 'P', NULL, 'Ds. Paron RT/RW : 11/03 Kec. Bagor Kab. Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'nurul.chofifah'), '20537588183001', 'Nurul Chofifah, S.Pd', 'P', NULL, 'Ds. Senjayan RT 02 RW 04 Kec. Gondang Kab. Nganjuk, 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'syaban.wulana'), '20537588196001', 'Moch. Syaban Wulana, S.Pd', 'L', NULL, 'Dusun Jatigetih RT 001/RW 005, Desa Sanggrahan Kec. Gondang, Kab. Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'winda.triyana'), '20537588198001', 'Winda Triyana, S.Pd', 'P', NULL, 'RT 01 RW 01, DESA JINTEL, KECAMATAN REJOSO, KABUPATEN NGANJUK', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'nopi.purwanti'), '20537588199002', 'Nopi Purwanti, S.Pd', 'P', NULL, 'RT.002/RW.011, DUSUN NGRAMBEK DESA CAMPUR KECAMATAN GONDANG KABUPATEN NGANJUK', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'kumala.azizatul'), '20537588100001', 'Kumala Azizatul Latifah, S.Pd', 'P', NULL, 'TB. Lancar berkah Jln. Nganjuk Bojonegoro, RT.01 ,RW 01, Dsn Sambikerep, Ds Sambikerep, Kec Rejoso, Kab. Nganjuk', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'titik.yuliati'), '20537992188001', 'Titik Yuliati, S.Pd', 'P', NULL, 'JL. CITARUM II NO.127, RT/RW: 02/04 BEGADUNG - NGANJUK', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'nur.fuad'), '20537507185001', 'Nur Fuad, S.H.I, M.A.', 'L', NULL, 'Desa Pandean RT 04/RW 02, Kec. Gondang, Kab. Nganjuk 64451', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'sulijadi'), NULL, 'Sulijadi, M.M', 'L', NULL, 'Gondang Kulon', NULL),
((SELECT `id` FROM `users` WHERE `username` = 'alita.dian'), NULL, 'Alita Dian Wahyu Shalikhah', 'P', NULL, 'Gondang Kulon', NULL);

-- D. DATA KELAS
INSERT INTO `classes` (`nama_kelas`, `tingkat`, `wali_kelas_id`) VALUES
('VIII A', '8', NULL),
('VIII B', '8', NULL),
('VIII C', '8', NULL),
('VIII D', '8', NULL);

-- E. DATA SISWA
SET @kelas_8A = (SELECT `id` FROM `classes` WHERE `nama_kelas` = 'VIII A' LIMIT 1);
SET @kelas_8B = (SELECT `id` FROM `classes` WHERE `nama_kelas` = 'VIII B' LIMIT 1);
SET @kelas_8C = (SELECT `id` FROM `classes` WHERE `nama_kelas` = 'VIII C' LIMIT 1);
SET @kelas_8D = (SELECT `id` FROM `classes` WHERE `nama_kelas` = 'VIII D' LIMIT 1);

INSERT INTO `siswas` (`user_id`, `kelas_id`, `nisn`, `nama_lengkap`, `jenis_kelamin`, `alamat`, `nama_wali`, `foto_url`) VALUES
((SELECT `id` FROM `users` WHERE `username` = 'ahmad.faiz'), @kelas_8A, '0127662965', 'Ahmad Faiz Nur Qolbi Asyari', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'ahmad.jazuli'), @kelas_8A, '0122355512', 'Ahmad Jazuli Wijaya', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'ahmadil.fuad'), @kelas_8A, '3131460024', 'Ahmadil Fu''ad Al Alwi', 'L', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'allfin.aditya'), @kelas_8A, '3123144201', 'Allfin Aditya Kurnia Putra', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'amanda.felicia'), @kelas_8A, '3125113021', 'Amanda Felicia Kusumajaya', 'P', 'DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'destin.natalia'), @kelas_8A, '0123741924', 'Destin Natalia Kusuma', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'dwi.saputra'), @kelas_8A, '3120286136', 'Dwi Saputra', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'faiz.maulana'), @kelas_8A, '0136508249', 'Faiz Maulana Azidan', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'fawwas.salman'), @kelas_8A, '0139764423', 'Fawwas Salman Alifi', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'jelita.anastasya'), @kelas_8A, '0129471609', 'Jelita Anastasya', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'julia.rahmahwati'), @kelas_8A, '0128457316', 'Julia Rahmahwati', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'kheshia.mey'), @kelas_8A, '0123738023', 'Kheshia Mey Azzahra', 'P', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'luky.afnan'), @kelas_8A, '0125830346', 'Luky Afnan Oktavian', 'L', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.aris'), @kelas_8A, '0127403990', 'Muhammad Aris Mulyadi', 'L', 'DSN. PANDEAN, DS. GONDANG PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'naafil.mubarokah'), @kelas_8A, '0123720553', 'Naafil Mubarokah', 'P', 'DSN. SAMBONG, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'moh.fazda'), @kelas_8A, '0117578051', 'Moh. Fazda Haziqol Mughietsa', 'L', 'CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'chayra.fayolla'), @kelas_8D, '3128531526', 'Chayra Fayolla Nazhiroh', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'ferendra.yubi'), @kelas_8D, '0133962880', 'M.Ferendra Yubi Haidar Afiar Yulianto', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'nabila.permatasari'), @kelas_8D, '0133809735', 'Nabila Permatasari', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'septia.lila'), @kelas_8D, '3122381181', 'Septia Lila Juariyah', 'P', 'DSN. KENTINGAN, DS. PUHKEREP REJOSO PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'sindi.candra'), @kelas_8D, '0128890869', 'Sindi Candra Winata', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'hafiz.kenzie'), @kelas_8B, '0124560956', 'Hafiz Kenzie Elano', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mariska.avril'), @kelas_8B, '0138598517', 'Mariska Avril Lutfianti', 'P', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.jayson'), @kelas_8B, '0124809726', 'Muhammad Jayson Azka Alfarizqi', 'L', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'novelia.qorry'), @kelas_8B, '3126950786', 'Novelia Qorry Nazzila', 'P', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'qurrotun.ainin'), @kelas_8B, '3121182277', 'Qurrotun Ainin Nadivah', 'P', 'DSN. SANGGRAHAN, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'rehan.maulana'), @kelas_8B, '0125388541', 'Rehan Maulana Ishaq', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'yuliana.dwi'), @kelas_8B, '0126925173', 'Yuliana Dwi Nur Chayanti', 'P', 'DSN. JATISARI, DS. NGANGKATAN NGANGKATAN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'afrian.angga'), @kelas_8B, '0127039881', 'Afrian Angga Yudistira', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'agiel.putra'), @kelas_8B, '0122124162', 'Agiel Putra Herlino', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'alfina.kholifah'), @kelas_8B, '0122769141', 'Alfina Kholifah', 'P', 'DSN KAMPUNG BARU PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'alica.zahra'), @kelas_8B, '3123980685', 'Alica Zahra Angraini', 'P', 'DUSUN KEDUNGREJO BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'annissa.dwi'), @kelas_8B, '0122098741', 'Annissa Dwi Novitasari', 'P', 'DSN. SENGGOWAR, DS. SENGGOWAR SENGGOWAR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'daryl.aydine'), @kelas_8B, '0131007102', 'Daryl Aydine Nugroho', 'L', 'DS. TALUN, REJOSO TALUN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'dimas.yongky'), @kelas_8B, '0123416714', 'Dimas Yongky Pramudika', 'L', 'DSN. BESUKI, DS. NGLINGGO NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'farrel.razqa'), @kelas_8B, '0129950827', 'Farrel Razqa Al Farizky', 'L', 'DS. TALUN, REJOSO TALUN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'kiara.laksita'), @kelas_8B, '0126770938', 'Kiara Laksita Ramadhani', 'P', 'DSN BESUKI NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'azhyfa.almedina'), @kelas_8B, '0121939595', 'Azhyfa Almedina Wijaya', 'P', 'DS. PANDEAN PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mohamad.rizqi'), @kelas_8D, '0121869487', 'Mohamad Rizqi Aldiansyah', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muchammad.rizqi'), @kelas_8D, '3126750130', 'Muchammad Rizqi Putra Pratama', 'L', 'DSN. PUHKEREP, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.eko'), @kelas_8D, '0125139495', 'Muhammad Eko Rifa''i', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.safii'), @kelas_8D, '3128724594', 'Muhammad Safi''i', 'L', 'DSN. KAWEDEGAN, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'halida.dwi'), @kelas_8C, '3120786159', 'Halida Dwi Mukhbitah', 'P', 'JL. RAYA GONDANG-NGLUYU KM. 1,7 SENGGOWAR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'lukman.affan'), @kelas_8C, '0127456938', 'Lukman Affan Oktavian', 'L', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.han'), @kelas_8C, '0127988378', 'Muhammad Han Al Wahid', 'L', 'DSN. NGLINGGO, DS. NGLINGGO NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'muhammad.rizal'), @kelas_8C, '0122473332', 'Muhammad Rizal Affandi', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'nur.syafa'), @kelas_8C, '3126201177', 'Nur Syafa Putri Ramadhani', 'P', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'putra.prasetyo'), @kelas_8C, '0126619547', 'Putra Prasetyo Adi Prayogo', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'wisnutama.syahdhan'), @kelas_8C, '0127677402', 'Wisnutama Syahdhan', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'wiwik.binti'), @kelas_8C, '0125494962', 'Wiwik Binti Aprelia', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'yeni.afissunani'), @kelas_8C, '0115017731', 'Yeni Afissunani', 'P', 'DSN. SAMBONG, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'kaisan.gree'), @kelas_8C, '0115914277', 'Kaisan Gree Ghiffary', 'L', 'JL. RAYA SUKOMORO-PACE KM. 1 KAPAS, SUKOMORO, NGANJUK, JAWA TIMUR, 64481', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mezzaluna.arsesha'), @kelas_8C, '3122832734', 'Mezzaluna Arsesha Setiawan', 'P', 'DUSUSN PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'moch.al'), @kelas_8C, '0123453484', 'Moch Al Nizam Putra Bahri', 'L', 'JL. JOYOBOYO II / 12 DUSUN TEPUS DESA SUKOREJO KECAMATAN NGASEM KABUPATEN KEDIRI SUKOREJO, NGASEM, KEDIRI, JAWA TIMUR, 64182', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mardiansyah.adi'), @kelas_8C, '0102224941', 'Mardiansyah Adi Saputra', 'L', 'DESA BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64452', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'andhi.putra'), @kelas_8C, '0113713659', 'Andhi Putra Maulana', 'L', 'DUSUN PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'andhika.putra'), @kelas_8C, '0111114726', 'Andhika Putra Maulana', 'L', 'DSN JINTEL, REJOSO JINTEL, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'verra.ananda'), @kelas_8D, '0122247568', 'Verra Ananda Meicha Putriatama', 'P', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'vickha.dwi'), @kelas_8D, '0137782431', 'Vickha Dwi Wahyuni', 'P', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'johan.rizki'), @kelas_8D, '0124350997', 'Johan Rizki Pratama', 'L', 'Dsn Ngrambek Desa Campur Kec. Gondang CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mohamad.farel'), @kelas_8D, '0138152999', 'Mohamad Farel Dwi Aditya', 'L', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mohammad.arfi'), @kelas_8D, '0129929586', 'Mohammad Arfi Eko Prasetyo', 'L', 'DSN. SAMBONG, DS. CAMPUR, GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = 'mohhamad.andika'), @kelas_8D, '0122721604', 'Mohhamad Andika Pratama', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL);

COMMIT;

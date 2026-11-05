-- ========================================================
-- DATABASE SYSTEM: APLIKASI MADRASAHKU (MTs AL-HUDA)
-- ========================================================

CREATE DATABASE IF NOT EXISTS `madrasahku_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `madrasahku_db`;

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

INSERT INTO `siswas` (`user_id`, `kelas_id`, `nisn`, `nama_lengkap`, `jenis_kelamin`, `alamat`, `nama_wali`, `foto_url`) VALUES
((SELECT `id` FROM `users` WHERE `username` = '0127662965'), @kelas_8A, '0127662965', 'Ahmad Faiz Nur Qolbi Asyari', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122355512'), @kelas_8A, '0122355512', 'Ahmad Jazuli Wijaya', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3131460024'), @kelas_8A, '3131460024', 'Ahmadil Fu''ad Al Alwi', 'L', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3123144201'), @kelas_8A, '3123144201', 'Allfin Aditya Kurnia Putra', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3125113021'), @kelas_8A, '3125113021', 'Amanda Felicia Kusumajaya', 'P', 'DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0123741924'), @kelas_8A, '0123741924', 'Destin Natalia Kusuma', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3120286136'), @kelas_8A, '3120286136', 'Dwi Saputra', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0136508249'), @kelas_8A, '0136508249', 'Faiz Maulana Azidan', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0139764423'), @kelas_8A, '0139764423', 'Fawwas Salman Alifi', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0129471609'), @kelas_8A, '0129471609', 'Jelita Anastasya', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0128457316'), @kelas_8A, '0128457316', 'Julia Rahmahwati', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0123738023'), @kelas_8A, '0123738023', 'Kheshia Mey Azzahra', 'P', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0125830346'), @kelas_8A, '0125830346', 'Luky Afnan Oktavian', 'L', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0127403990'), @kelas_8A, '0127403990', 'Muhammad Aris Mulyadi', 'L', 'DSN. PANDEAN, DS. GONDANG PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0123720553'), @kelas_8A, '0123720553', 'Naafil Mubarokah', 'P', 'DSN. SAMBONG, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0117578051'), @kelas_8A, '0117578051', 'Moh. Fazda Haziqol Mughietsa', 'L', 'CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3128531526'), @kelas_8D, '3128531526', 'Chayra Fayolla Nazhiroh', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0133962880'), @kelas_8D, '0133962880', 'M.Ferendra Yubi Haidar Afiar Yulianto', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0133809735'), @kelas_8D, '0133809735', 'Nabila Permatasari', 'P', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3122381181'), @kelas_8D, '3122381181', 'Septia Lila Juariyah', 'P', 'DSN. KENTINGAN, DS. PUHKEREP REJOSO PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0128890869'), @kelas_8D, '0128890869', 'Sindi Candra Winata', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0124560956'), @kelas_8B, '0124560956', 'Hafiz Kenzie Elano', 'L', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0138598517'), @kelas_8B, '0138598517', 'Mariska Avril Lutfianti', 'P', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0124809726'), @kelas_8B, '0124809726', 'Muhammad Jayson Azka Alfarizqi', 'L', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3126950786'), @kelas_8B, '3126950786', 'Novelia Qorry Nazzila', 'P', 'DSN. BALONGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3121182277'), @kelas_8B, '3121182277', 'Qurrotun Ainin Nadivah', 'P', 'DSN. SANGGRAHAN, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0125388541'), @kelas_8B, '0125388541', 'Rehan Maulana Ishaq', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0126925173'), @kelas_8B, '0126925173', 'Yuliana Dwi Nur Chayanti', 'P', 'DSN. JATISARI, DS. NGANGKATAN NGANGKATAN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0127039881'), @kelas_8B, '0127039881', 'Afrian Angga Yudistira', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122124162'), @kelas_8B, '0122124162', 'Agiel Putra Herlino', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122769141'), @kelas_8B, '0122769141', 'Alfina Kholifah', 'P', 'DSN KAMPUNG BARU PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3123980685'), @kelas_8B, '3123980685', 'Alica Zahra Angraini', 'P', 'DUSUN KEDUNGREJO BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122098741'), @kelas_8B, '0122098741', 'Annissa Dwi Novitasari', 'P', 'DSN. SENGGOWAR, DS. SENGGOWAR SENGGOWAR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0131007102'), @kelas_8B, '0131007102', 'Daryl Aydine Nugroho', 'L', 'DS. TALUN, REJOSO TALUN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0123416714'), @kelas_8B, '0123416714', 'Dimas Yongky Pramudika', 'L', 'DSN. BESUKI, DS. NGLINGGO NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0129950827'), @kelas_8B, '0129950827', 'Farrel Razqa Al Farizky', 'L', 'DS. TALUN, REJOSO TALUN, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0126770938'), @kelas_8B, '0126770938', 'Kiara Laksita Ramadhani', 'P', 'DSN BESUKI NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0121939595'), @kelas_8B, '0121939595', 'Azhyfa Almedina Wijaya', 'P', 'DS. PANDEAN PANDEAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0121869487'), @kelas_8D, '0121869487', 'Mohamad Rizqi Aldiansyah', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3126750130'), @kelas_8D, '3126750130', 'Muchammad Rizqi Putra Pratama', 'L', 'DSN. PUHKEREP, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0125139495'), @kelas_8D, '0125139495', 'Muhammad Eko Rifa''i', 'L', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3128724594'), @kelas_8D, '3128724594', 'Muhammad Safi''i', 'L', 'DSN. KAWEDEGAN, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3120786159'), @kelas_8C, '3120786159', 'Halida Dwi Mukhbitah', 'P', 'JL. RAYA GONDANG-NGLUYU KM. 1,7 SENGGOWAR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0127456938'), @kelas_8C, '0127456938', 'Lukman Affan Oktavian', 'L', 'DSN. SUKOREJO, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0127988378'), @kelas_8C, '0127988378', 'Muhammad Han Al Wahid', 'L', 'DSN. NGLINGGO, DS. NGLINGGO NGLINGGO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122473332'), @kelas_8C, '0122473332', 'Muhammad Rizal Affandi', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3126201177'), @kelas_8C, '3126201177', 'Nur Syafa Putri Ramadhani', 'P', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0126619547'), @kelas_8C, '0126619547', 'Putra Prasetyo Adi Prayogo', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0127677402'), @kelas_8C, '0127677402', 'Wisnutama Syahdhan', 'L', 'DSN. KEDUNGREJO, DS. BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0125494962'), @kelas_8C, '0125494962', 'Wiwik Binti Aprelia', 'P', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0115017731'), @kelas_8C, '0115017731', 'Yeni Afissunani', 'P', 'DSN. SAMBONG, DS. GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0115914277'), @kelas_8C, '0115914277', 'Kaisan Gree Ghiffary', 'L', 'JL. RAYA SUKOMORO-PACE KM. 1 KAPAS, SUKOMORO, NGANJUK, JAWA TIMUR, 64481', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '3122832734'), @kelas_8C, '3122832734', 'Mezzaluna Arsesha Setiawan', 'P', 'DUSUSN PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0123453484'), @kelas_8C, '0123453484', 'Moch Al Nizam Putra Bahri', 'L', 'JL. JOYOBOYO II / 12 DUSUN TEPUS DESA SUKOREJO KECAMATAN NGASEM KABUPATEN KEDIRI SUKOREJO, NGASEM, KEDIRI, JAWA TIMUR, 64182', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0102224941'), @kelas_8C, '0102224941', 'Mardiansyah Adi Saputra', 'L', 'DESA BALONGGEBANG BALONGGEBANG, GONDANG, NGANJUK, JAWA TIMUR, 64452', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0113713659'), @kelas_8C, '0113713659', 'Andhi Putra Maulana', 'L', 'DUSUN PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0111114726'), @kelas_8C, '0111114726', 'Andhika Putra Maulana', 'L', 'DSN JINTEL, REJOSO JINTEL, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122247568'), @kelas_8D, '0122247568', 'Verra Ananda Meicha Putriatama', 'P', 'DSN. NGRAMBEK, DS. CAMPUR CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0137782431'), @kelas_8D, '0137782431', 'Vickha Dwi Wahyuni', 'P', 'DSN. KENTINGAN, DS. PUHKEREP PUHKEREP, REJOSO, NGANJUK, JAWA TIMUR, 64453', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0124350997'), @kelas_8D, '0124350997', 'Johan Rizki Pratama', 'L', 'Dsn Ngrambek Desa Campur Kec. Gondang CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0138152999'), @kelas_8D, '0138152999', 'Mohamad Farel Dwi Aditya', 'L', 'DSN. NGASEM, DS. SUMBERJO SUMBERJO, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0129929586'), @kelas_8D, '0129929586', 'Mohammad Arfi Eko Prasetyo', 'L', 'DSN. SAMBONG, DS. CAMPUR, GONDANG CAMPUR, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL),
((SELECT `id` FROM `users` WHERE `username` = '0122721604'), @kelas_8D, '0122721604', 'Mohhamad Andika Pratama', 'L', 'DSN. JATIGETIH, DS. SANGGRAHAN SANGGRAHAN, GONDANG, NGANJUK, JAWA TIMUR, 64451', NULL, NULL);

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

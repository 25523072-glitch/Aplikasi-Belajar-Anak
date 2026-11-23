-- =====================================================================
-- Website Pembelajaran Anak (Kelompok Ayam Sayur, PABW 2026/2027)
-- Skrip pembuatan database sesuai ERD kelompok (8 tabel)
-- Cara pakai: phpMyAdmin -> tab Import -> pilih file ini -> Import
-- Diuji di MariaDB (XAMPP) dan MySQL 8
-- =====================================================================

CREATE DATABASE IF NOT EXISTS belajar_anak
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE belajar_anak;

-- Hapus tabel lama (urutan dari tabel anak ke tabel induk)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS percobaan_game, percobaan_kuis, pilihan_jawaban,
                     soal, game, materi, anak, pengguna;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. PENGGUNA: pendamping (orang tua/guru) dan admin
-- ---------------------------------------------------------------------
CREATE TABLE pengguna (
  id_pengguna    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama           VARCHAR(100) NOT NULL,
  email          VARCHAR(100) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,           -- isi dengan password_hash() dari PHP
  peran          ENUM('pendamping','admin') NOT NULL DEFAULT 'pendamping',
  PRIMARY KEY (id_pengguna),
  UNIQUE KEY uk_pengguna_email (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. ANAK: akun anak, dibuat oleh satu pendamping
-- ---------------------------------------------------------------------
CREATE TABLE anak (
  id_anak         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pengguna     INT UNSIGNED NOT NULL,
  nama_pengguna   VARCHAR(50)  NOT NULL,
  pin_hash        VARCHAR(255) NOT NULL,          -- PIN disimpan dalam bentuk hash
  avatar          VARCHAR(100) NULL,
  tanggal_daftar  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_anak),
  UNIQUE KEY uk_anak_nama_pengguna (nama_pengguna),
  CONSTRAINT fk_anak_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna (id_pengguna) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. MATERI: materi baca-tulis dan berhitung bergambar
-- ---------------------------------------------------------------------
CREATE TABLE materi (
  id_materi  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  judul      VARCHAR(100) NOT NULL,
  kategori   VARCHAR(30)  NOT NULL,               -- huruf, suku kata, kata, angka, hitung
  isi        TEXT         NOT NULL,
  gambar     VARCHAR(255) NULL,
  urutan     INT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (id_materi)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. SOAL: soal kuis milik satu materi
-- ---------------------------------------------------------------------
CREATE TABLE soal (
  id_soal     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_materi   INT UNSIGNED NOT NULL,
  pertanyaan  VARCHAR(255) NOT NULL,
  gambar      VARCHAR(255) NULL,
  PRIMARY KEY (id_soal),
  CONSTRAINT fk_soal_materi FOREIGN KEY (id_materi)
    REFERENCES materi (id_materi) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PILIHAN_JAWABAN: beberapa pilihan per soal, satu yang benar
-- ---------------------------------------------------------------------
CREATE TABLE pilihan_jawaban (
  id_pilihan     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_soal        INT UNSIGNED NOT NULL,
  teks_pilihan   VARCHAR(100) NOT NULL,
  benar          TINYINT(1)   NOT NULL DEFAULT 0, -- 1 = jawaban benar
  PRIMARY KEY (id_pilihan),
  CONSTRAINT fk_pilihan_soal FOREIGN KEY (id_soal)
    REFERENCES soal (id_soal) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. PERCOBAAN_KUIS: satu kali anak mengerjakan kuis suatu materi
--    (jembatan anak-materi; boleh diulang, jadi punya PK sendiri)
--    Bintang TIDAK disimpan, dihitung dari skor (lihat contoh di bawah).
-- ---------------------------------------------------------------------
CREATE TABLE percobaan_kuis (
  id_percobaan   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_anak        INT UNSIGNED NOT NULL,
  id_materi      INT UNSIGNED NOT NULL,
  waktu_mulai    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_selesai  DATETIME     NULL,               -- NULL = belum selesai
  skor           INT UNSIGNED NOT NULL DEFAULT 0, -- 0 sampai 100
  PRIMARY KEY (id_percobaan),
  CONSTRAINT fk_pkuis_anak FOREIGN KEY (id_anak)
    REFERENCES anak (id_anak) ON DELETE CASCADE,
  CONSTRAINT fk_pkuis_materi FOREIGN KEY (id_materi)
    REFERENCES materi (id_materi) ON DELETE RESTRICT,
  CONSTRAINT ck_pkuis_waktu CHECK (waktu_selesai IS NULL OR waktu_selesai >= waktu_mulai),
  CONSTRAINT ck_pkuis_skor CHECK (skor <= 100)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. GAME: daftar game edukasi
-- ---------------------------------------------------------------------
CREATE TABLE game (
  id_game    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_game  VARCHAR(100) NOT NULL,
  deskripsi  VARCHAR(255) NULL,
  PRIMARY KEY (id_game)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. PERCOBAAN_GAME: satu kali anak memainkan sebuah game
--    (jembatan anak-game)
-- ---------------------------------------------------------------------
CREATE TABLE percobaan_game (
  id_percobaan_game  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_anak            INT UNSIGNED NOT NULL,
  id_game            INT UNSIGNED NOT NULL,
  waktu_mulai        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_selesai      DATETIME     NULL,
  skor               INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_percobaan_game),
  CONSTRAINT fk_pgame_anak FOREIGN KEY (id_anak)
    REFERENCES anak (id_anak) ON DELETE CASCADE,
  CONSTRAINT fk_pgame_game FOREIGN KEY (id_game)
    REFERENCES game (id_game) ON DELETE RESTRICT,
  CONSTRAINT ck_pgame_waktu CHECK (waktu_selesai IS NULL OR waktu_selesai >= waktu_mulai)
) ENGINE=InnoDB;

-- =====================================================================
-- DATA CONTOH (untuk demo dan halaman materi)
-- Hash di bawah hanya contoh palsu; ganti lewat password_hash() di PHP.
-- =====================================================================
INSERT INTO pengguna (nama, email, password_hash, peran) VALUES
  ('Ibu Rina',      'rina@contoh.id',  '$2y$10$GANTI_DENGAN_HASH_ASLI_1', 'pendamping'),
  ('Admin Belajar', 'admin@contoh.id', '$2y$10$GANTI_DENGAN_HASH_ASLI_2', 'admin');

INSERT INTO anak (id_pengguna, nama_pengguna, pin_hash, avatar) VALUES
  (1, 'adit_kelinci', '$2y$10$GANTI_DENGAN_HASH_PIN_1', 'kelinci.png'),
  (1, 'sari_kucing',  '$2y$10$GANTI_DENGAN_HASH_PIN_2', 'kucing.png');

INSERT INTO materi (judul, kategori, isi, gambar, urutan) VALUES
  ('Mengenal Huruf A, B, C', 'huruf',     'A untuk Apel, B untuk Bola, C untuk Cicak.', 'huruf_abc.png', 1),
  ('Suku Kata Ba, Bi, Bu',   'suku kata', 'Ba, Bi, Bu, Be, Bo. Ayo ucapkan bersama!',   'suku_ba.png',  2),
  ('Membaca Kata: ibu, sapi','kata',      'i-bu = ibu, sa-pi = sapi.',                  'kata_ibu.png', 3),
  ('Mengenal Angka 1 sampai 5','angka',   'Hitung apel di meja: 1, 2, 3, 4, 5.',        'angka_15.png', 4);

INSERT INTO soal (id_materi, pertanyaan) VALUES
  (4, 'Ada 3 apel di meja. Berapa jumlah apelnya?'),
  (4, 'Angka berapa yang ada setelah 4?');

INSERT INTO pilihan_jawaban (id_soal, teks_pilihan, benar) VALUES
  (1, '2', 0), (1, '3', 1), (1, '5', 0),
  (2, '3', 0), (2, '5', 1), (2, '1', 0);

INSERT INTO game (nama_game, deskripsi) VALUES
  ('Cocokkan Huruf dan Gambar', 'Pasangkan huruf dengan gambar yang awalnya sama.');

INSERT INTO percobaan_kuis (id_anak, id_materi, waktu_mulai, waktu_selesai, skor) VALUES
  (1, 4, '2026-11-20 09:00:00', '2026-11-20 09:06:30', 80),
  (1, 4, '2026-11-21 09:00:00', '2026-11-21 09:05:10', 100),
  (2, 4, '2026-11-21 10:00:00', NULL, 0);

INSERT INTO percobaan_game (id_anak, id_game, waktu_mulai, waktu_selesai, skor) VALUES
  (1, 1, '2026-11-20 09:10:00', '2026-11-20 09:18:00', 60);

-- =====================================================================
-- CONTOH QUERY: bintang dan durasi dihitung, tidak disimpan di tabel
-- =====================================================================
SELECT a.nama_pengguna,
       m.judul,
       p.skor,
       CASE WHEN p.skor >= 80 THEN 3
            WHEN p.skor >= 50 THEN 2
            ELSE 1 END                                         AS bintang,
       TIMESTAMPDIFF(MINUTE, p.waktu_mulai, p.waktu_selesai)   AS durasi_menit
FROM percobaan_kuis p
JOIN anak   a ON a.id_anak   = p.id_anak
JOIN materi m ON m.id_materi = p.id_materi
WHERE p.waktu_selesai IS NOT NULL;

-- =====================================================================
-- 01_skema.sql : Skema Website Pembelajaran Anak (Kelompok Ayam Sayur)
-- Simpan di repository kelompok: docs/erd/01_skema.sql
-- Jalankan pada basis data kosong. P21 dimulai dari skema ini.
-- =====================================================================
CREATE DATABASE IF NOT EXISTS belajar_anak DEFAULT CHARACTER SET utf8mb4;
USE belajar_anak;

-- Hapus tabel lama bila ada (urutan hapus = kebalikan urutan buat)
DROP TABLE IF EXISTS percobaan_game;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS percobaan_kuis;
DROP TABLE IF EXISTS pilihan_jawaban;
DROP TABLE IF EXISTS soal;
DROP TABLE IF EXISTS materi;
DROP TABLE IF EXISTS anak;
DROP TABLE IF EXISTS pengguna;

-- 1. pengguna: pendamping (orang tua/guru) dan admin -------------------
CREATE TABLE pengguna (
  id_pengguna    INT          NOT NULL AUTO_INCREMENT,
  nama           VARCHAR(100) NOT NULL,
  email          VARCHAR(100) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  peran          ENUM('pendamping','admin') NOT NULL DEFAULT 'pendamping',
  PRIMARY KEY (id_pengguna),
  UNIQUE KEY uk_pengguna_email (email)
) ENGINE=InnoDB;

-- 2. anak: akun anak, dibuat oleh satu pendamping (1:N, aturan 4) -----
CREATE TABLE anak (
  id_anak         INT          NOT NULL AUTO_INCREMENT,
  nama_pengguna   VARCHAR(50)  NOT NULL,
  pin_hash        VARCHAR(255) NOT NULL,
  avatar          VARCHAR(100) NULL,
  tanggal_daftar  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_pengguna     INT          NOT NULL,
  PRIMARY KEY (id_anak),
  UNIQUE KEY uk_anak_nama_pengguna (nama_pengguna),
  CONSTRAINT fk_anak_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. materi -----------------------------------------------------------
CREATE TABLE materi (
  id_materi  INT          NOT NULL AUTO_INCREMENT,
  judul      VARCHAR(100) NOT NULL,
  kategori   VARCHAR(30)  NOT NULL,
  isi        TEXT         NOT NULL,
  gambar     VARCHAR(255) NULL,
  urutan     INT          NOT NULL DEFAULT 1,
  PRIMARY KEY (id_materi),
  CONSTRAINT ck_materi_urutan CHECK (urutan >= 1)
) ENGINE=InnoDB;

-- 4. soal: soal kuis milik satu materi (1:N) --------------------------
CREATE TABLE soal (
  id_soal     INT          NOT NULL AUTO_INCREMENT,
  pertanyaan  VARCHAR(255) NOT NULL,
  gambar      VARCHAR(255) NULL,
  id_materi   INT          NOT NULL,
  PRIMARY KEY (id_soal),
  CONSTRAINT fk_soal_materi
    FOREIGN KEY (id_materi) REFERENCES materi(id_materi)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. pilihan_jawaban: pilihan per soal, satu yang benar (1:N) ---------
CREATE TABLE pilihan_jawaban (
  id_pilihan    INT          NOT NULL AUTO_INCREMENT,
  teks_pilihan  VARCHAR(100) NOT NULL,
  benar         TINYINT(1)   NOT NULL DEFAULT 0,
  id_soal       INT          NOT NULL,
  PRIMARY KEY (id_pilihan),
  CONSTRAINT ck_pilihan_benar CHECK (benar IN (0,1)),
  CONSTRAINT fk_pilihan_soal
    FOREIGN KEY (id_soal) REFERENCES soal(id_soal)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. percobaan_kuis: jembatan anak-materi dengan PK sendiri -----------
--    (anak boleh mengulang kuis yang sama, jadi PK gabungan tidak cukup)
CREATE TABLE percobaan_kuis (
  id_percobaan   INT      NOT NULL AUTO_INCREMENT,
  waktu_mulai    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_selesai  DATETIME NULL,
  skor           INT      NOT NULL DEFAULT 0,
  id_anak        INT      NOT NULL,
  id_materi      INT      NOT NULL,
  PRIMARY KEY (id_percobaan),
  CONSTRAINT ck_pkuis_skor  CHECK (skor BETWEEN 0 AND 100),
  CONSTRAINT ck_pkuis_waktu CHECK (waktu_selesai IS NULL OR waktu_selesai >= waktu_mulai),
  CONSTRAINT fk_pkuis_anak
    FOREIGN KEY (id_anak) REFERENCES anak(id_anak)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pkuis_materi
    FOREIGN KEY (id_materi) REFERENCES materi(id_materi)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. game -------------------------------------------------------------
CREATE TABLE game (
  id_game    INT          NOT NULL AUTO_INCREMENT,
  nama_game  VARCHAR(100) NOT NULL,
  deskripsi  VARCHAR(255) NULL,
  PRIMARY KEY (id_game)
) ENGINE=InnoDB;

-- 8. percobaan_game: jembatan anak-game dengan PK sendiri -------------
CREATE TABLE percobaan_game (
  id_percobaan_game  INT      NOT NULL AUTO_INCREMENT,
  waktu_mulai        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_selesai      DATETIME NULL,
  skor               INT      NOT NULL DEFAULT 0,
  id_anak            INT      NOT NULL,
  id_game            INT      NOT NULL,
  PRIMARY KEY (id_percobaan_game),
  CONSTRAINT ck_pgame_skor  CHECK (skor >= 0),
  CONSTRAINT ck_pgame_waktu CHECK (waktu_selesai IS NULL OR waktu_selesai >= waktu_mulai),
  CONSTRAINT fk_pgame_anak
    FOREIGN KEY (id_anak) REFERENCES anak(id_anak)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pgame_game
    FOREIGN KEY (id_game) REFERENCES game(id_game)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

# Skema Relasional: Website Pembelajaran Anak

Kelompok Ayam Sayur (Kelas E), PABW 2026/2027.
Basis data: `belajar_anak`. Dibangun dari `01_skema.sql`. Diagram: `erd_kelompok_ayam_sayur.png`.

Notasi: `nama_tabel(PK, kolom, FK)`. **Tebal** = primary key, *miring* = foreign key.

## Skema (8 tabel, urutan buat dari induk ke anak)

1. `pengguna`(**id_pengguna**, nama, email, password_hash, peran)
   FK: tidak ada
2. `anak`(**id_anak**, nama_pengguna, pin_hash, avatar, tanggal_daftar, *id_pengguna*)
   FK: id_pengguna → pengguna
3. `materi`(**id_materi**, judul, kategori, isi, gambar, urutan)
   FK: tidak ada
4. `soal`(**id_soal**, pertanyaan, gambar, *id_materi*)
   FK: id_materi → materi
5. `pilihan_jawaban`(**id_pilihan**, teks_pilihan, benar, *id_soal*)
   FK: id_soal → soal
6. `percobaan_kuis`(**id_percobaan**, waktu_mulai, waktu_selesai, skor, *id_anak*, *id_materi*)
   FK: id_anak → anak; id_materi → materi
7. `game`(**id_game**, nama_game, deskripsi)
   FK: tidak ada
8. `percobaan_game`(**id_percobaan_game**, waktu_mulai, waktu_selesai, skor, *id_anak*, *id_game*)
   FK: id_anak → anak; id_game → game

## Aturan pemetaan yang dipakai

| Aturan | Penerapan |
|---|---|
| 1. Entitas kuat | Setiap entitas menjadi satu tabel |
| 4. Relasi 1:N | FK di sisi "banyak" (anak, soal, pilihan_jawaban, percobaan_kuis, percobaan_game) |
| 5. Relasi M:N | Anak–materi dan anak–game dijembatani `percobaan_kuis` dan `percobaan_game` |

## Keputusan perancangan

- `percobaan_kuis` dan `percobaan_game` memakai PK buatan sendiri, bukan PK gabungan `(id_anak, id_materi)`. Anak boleh mengulang kuis atau game yang sama, sehingga pasangan anak–materi tidak unik. Keduanya adalah entitas peristiwa (punya waktu dan skor).
- Bintang **tidak disimpan**. Bintang adalah nilai turunan dari skor dan dihitung saat ditampilkan.
- Durasi pemakaian **tidak disimpan**. Dihitung dari `waktu_selesai - waktu_mulai`.
- `waktu_selesai` boleh NULL, artinya percobaan belum selesai.
- ON DELETE: `soal` dan `pilihan_jawaban` mengikuti induknya (CASCADE) karena tidak bermakna tanpa induk. FK lain RESTRICT agar riwayat belajar tidak hilang tanpa sengaja.

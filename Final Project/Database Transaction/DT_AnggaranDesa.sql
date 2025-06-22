-- Manajemen Anggaran Desa
BEGIN;

-- Tambah anggaran tahunan
INSERT INTO Anggaran_Desa (id_anggaran, tahun, total_anggaran, keterangan)
VALUES (500, 2026, 1000000000.00, 'Anggaran Tahun 2026');

-- Tambah alokasi dana proyek A
INSERT INTO Sumber_Dana (id_sumber_dana, id_anggaran_tahunan, id_proyek, nama_kegiatan, kategori, pagu_anggaran, tanggal_alokasi, keterangan)
VALUES 
(1001, 500, NULL, 'Pelatihan Warga', 'SDM', 200000000.00, '2026-01-05', 'Pelatihan kerja warga desa');

-- Savepoint setelah alokasi pertama
SAVEPOINT alokasi_1;

-- Tambah alokasi dana proyek B (tidak valid - pagu terlalu besar)
INSERT INTO Sumber_Dana (id_sumber_dana, id_anggaran_tahunan, id_proyek, nama_kegiatan, kategori, pagu_anggaran, tanggal_alokasi, keterangan)
VALUES 
(1002, 500, NULL, 'Pengadaan Mobil', 'Aset', 900000000.00, '2026-01-06', 'Melebihi anggaran');

-- Rollback karena melebihi total anggaran
ROLLBACK TO SAVEPOINT alokasi_1;

-- Ganti dengan pagu wajar
INSERT INTO Sumber_Dana (id_sumber_dana, id_anggaran_tahunan, id_proyek, nama_kegiatan, kategori, pagu_anggaran, tanggal_alokasi, keterangan)
VALUES 
(1003, 500, NULL, 'Pengadaan Laptop', 'Aset', 150000000.00, '2026-01-07', 'Laptop untuk administrasi');

COMMIT;

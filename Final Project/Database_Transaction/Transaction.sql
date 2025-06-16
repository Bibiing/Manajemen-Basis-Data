EXAMPLE

-- Awal transaksi
BEGIN;

-- 1. Tambahkan Anggaran Tahun 2025
INSERT INTO Anggaran_Desa (id_anggaran, tahun, total_anggaran, keterangan)
VALUES (101, 2025, 500000000.00, 'Anggaran Dana Desa Tahun 2025');

-- 2. Tambahkan Proyek Pembangunan
INSERT INTO Proyek_Pembangunan (id_proyek, nama_proyek, deskripsi, tanggal_mulai, tanggal_selesai, status_proyek, persentase_progress)
VALUES (201, 'Pembangunan Jalan Desa', 'Aspal jalan utama sepanjang 1 km', '2025-01-10', '2025-03-30', 'Berjalan', 20.00);

-- 3. Tambahkan Alokasi Dana ke Proyek
INSERT INTO Sumber_Dana (id_sumber_dana, id_anggaran_tahunan, id_proyek, nama_kegiatan, kategori, pagu_anggaran, tanggal_alokasi, keterangan)
VALUES 
(301, 101, 201, 'Pengadaan Material', 'Infrastruktur', 200000000.00, '2025-01-15', 'Material jalan');

-- 4. Tambahkan transaksi belanja awal
INSERT INTO Transaksi_Realisasi (id_transaksi, id_sumber_dana, deskripsi_belanja, jumlah_belanja, tanggal_transaksi, penerima_dana, dicatat_oleh)
VALUES 
(401, 301, 'Pembelian batu split', 50000000.00, '2025-01-20', 'CV Bangun Desa', 'Bendahara Desa'),
(402, 301, 'Sewa alat berat', 30000000.00, '2025-01-21', 'PT Rental Alat', 'Bendahara Desa');

-- Simpan checkpoint transaksi awal
SAVEPOINT awal_realisasi;

-- 5. Tambahkan transaksi lanjutan
INSERT INTO Transaksi_Realisasi (id_transaksi, id_sumber_dana, deskripsi_belanja, jumlah_belanja, tanggal_transaksi, penerima_dana, dicatat_oleh)
VALUES 
(403, 301, 'Biaya konsumsi pekerja', 20000000.00, '2025-01-22', 'Warung Ibu Siti', 'Bendahara Desa');

-- Oops! Terdeteksi kesalahan penginputan
ROLLBACK TO SAVEPOINT awal_realisasi;

-- 6. Masukkan transaksi pengganti yang benar
INSERT INTO Transaksi_Realisasi (id_transaksi, id_sumber_dana, deskripsi_belanja, jumlah_belanja, tanggal_transaksi, penerima_dana, dicatat_oleh)
VALUES 
(404, 301, 'Upah pekerja harian', 40000000.00, '2025-01-22', 'Warga Setempat', 'Bendahara Desa');

-- Simpan semua perubahan
COMMIT;

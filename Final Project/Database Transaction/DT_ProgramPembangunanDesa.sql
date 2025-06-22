-- Manajemen Program Pembangunan Desa

BEGIN;

-- Tambah proyek pembangunan
INSERT INTO Proyek_Pembangunan (id_proyek, nama_proyek, deskripsi, tanggal_mulai, tanggal_selesai, status_proyek, persentase_progress)
VALUES 
(200, 'Pembangunan Balai Desa', 'Membangun gedung balai desa baru', '2025-02-01', '2025-06-01', 'Berjalan', 10.00);

-- Savepoint awal progres
SAVEPOINT awal_progress;

-- Update progres, tapi salah input 5%
UPDATE Proyek_Pembangunan 
SET persentase_progress = 5.00
WHERE id_proyek = 200;

-- Rollback karena progress malah menurun
ROLLBACK TO SAVEPOINT awal_progress;

-- Update progres yang benar
UPDATE Proyek_Pembangunan 
SET persentase_progress = 25.00
WHERE id_proyek = 200;

COMMIT;

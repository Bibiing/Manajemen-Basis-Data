-- Manajemen Pendataan Penduduk
BEGIN;

-- Tambah data keluarga
INSERT INTO Keluarga (id_keluarga, no_kk, alamat, jumlah_anggota)
VALUES (200001, '1234567890123456', 'Jl. Melati No. 10', 4);

-- Tambah data warga
INSERT INTO Warga (id_warga, nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
VALUES 
(500001, '3210987654321001', 'Ahmad', '1990-04-15', 'Laki-laki', 'Kawin', 'S1', 'Guru', 'Mampu', 200001),
(500002, '3210987654321002', 'Ayu', '1992-06-20', 'Perempuan', 'Kawin', 'S1', 'Dokter', 'Mampu', 200001);

-- Simpan savepoint awal input
SAVEPOINT awal_input_warga;

-- Tambah warga salah input
INSERT INTO Warga (id_warga, nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
VALUES 
(500003, '1234567891011121', 'SALAH', '2020-01-01', 'Laki-laki', 'Belum Kawin', 'SD', 'Tidak Jelas', 'Tidak Mampu', 200001);

-- Rollback karena salah input
ROLLBACK TO SAVEPOINT awal_input_warga;

-- Tambah data pengganti yang benar
INSERT INTO Warga (id_warga, nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
VALUES 
(500003, '3210987654321003', 'Bayu', '2010-05-25', 'Laki-laki', 'Belum Kawin', 'SMP', NULL, 'Cukup Mampu', 200001);

COMMIT;

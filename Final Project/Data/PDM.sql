-- =================================================================
-- PDM
-- =================================================================

-- B: MANAJEMEN PENDATAAN PENDUDUK
-- =================================================================

CREATE TABLE Keluarga (
    id_keluarga BIGINT PRIMARY KEY,
    no_kk CHAR(16) NOT NULL UNIQUE,
    alamat VARCHAR(255) NOT NULL,
	jumlah_anggota INTEGER NOT NULL
);

CREATE TABLE Warga (
    id_warga BIGINT PRIMARY KEY,
    nik CHAR(16) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin VARCHAR(10) NOT NULL CHECK (jenis_kelamin IN ('Laki-laki', 'Perempuan')), 
    status_perkawinan VARCHAR(50),
    pendidikan_terakhir VARCHAR(50),
    pekerjaan VARCHAR(100),
    status_ekonomi VARCHAR(50),
    id_keluarga BIGINT NOT NULL, 
    FOREIGN KEY (id_keluarga) REFERENCES Keluarga(id_keluarga)
);

-- C: MANAJEMEN ANGGARAN DESA
-- =================================================================

CREATE TABLE Anggaran_Desa (
    id_anggaran BIGINT PRIMARY KEY,
    tahun INT NOT NULL,
    total_anggaran DECIMAL(18, 2) NOT NULL, 
    keterangan TEXT
);

-- D: MANAJEMEN PROGRAM PEMBANGUNAN DESA
-- =================================================================

CREATE TABLE Proyek_Pembangunan (
    id_proyek BIGINT PRIMARY KEY,
    nama_proyek VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    status_proyek VARCHAR(50),
    persentase_progress DECIMAL(5, 2) DEFAULT 0.00, 
    CHECK (persentase_progress BETWEEN 0 AND 100)
);


-- TABEL ANGGARAN DAN PROYEK (C & D)
-- =================================================================

-- Sumber_Dana : (hanya untuk perencanaan)
CREATE TABLE Sumber_Dana (
    id_sumber_dana BIGINT PRIMARY KEY,
    id_anggaran_tahunan BIGINT NOT NULL,  
    id_proyek BIGINT NULL,             
    nama_kegiatan VARCHAR(255) NOT NULL,
    kategori VARCHAR(100),            
    pagu_anggaran DECIMAL(18, 2) NOT NULL, 
    tanggal_alokasi DATE NOT NULL,     
    keterangan TEXT,
    FOREIGN KEY (id_anggaran_tahunan) REFERENCES Anggaran_Desa(id_anggaran)
);

CREATE TABLE Transaksi_Realisasi (
    id_transaksi BIGINT PRIMARY KEY,
    id_sumber_dana BIGINT NOT NULL, 
    deskripsi_belanja VARCHAR(255) NOT NULL, 
    jumlah_belanja DECIMAL(18, 2) NOT NULL,  
    tanggal_transaksi DATE NOT NULL,         
    penerima_dana VARCHAR(150),              
    bukti_pembayaran VARCHAR(255) NULL, 
    dicatat_oleh VARCHAR(100),
    FOREIGN KEY (id_sumber_dana) REFERENCES Sumber_Dana(id_sumber_dana)
);


-- Tabel Manajemen Pelayanan Warga (A)
-- =================================================================

CREATE TABLE Jenis_Surat (
    id_jenis BIGINT PRIMARY KEY,
    nama_surat VARCHAR(100) NOT NULL,
    keterangan TEXT
);

CREATE TYPE status_permohonan_enum AS ENUM (
  'Diajukan',
  'Diverifikasi',
  'Ditolak',
  'Selesai',
  'Sudah Diambil',
);

CREATE TABLE Permohonan_Surat (
    id_permohonan BIGINT PRIMARY KEY,
    id_warga BIGINT NOT NULL,
    id_jenis BIGINT NOT NULL,
    tanggal_permohonan DATE NOT NULL,
    tanggal_verifikasi TIMESTAMP NULL,
    tanggal_selesai_diproses TIMESTAMP NULL,
    tanggal_diambil_warga TIMESTAMP NULL,
    status_permohonan status_permohonan_enum NOT NULL DEFAULT 'Diajukan',
    catatan TEXT,
    verifikator VARCHAR(100) NULL,
    FOREIGN KEY (id_warga) REFERENCES Warga(id_warga),
    FOREIGN KEY (id_jenis) REFERENCES Jenis_Surat(id_jenis)
);

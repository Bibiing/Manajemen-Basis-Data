-- PERBAIKAN UNTUK TABEL ANGGARAN_DESA
CREATE SEQUENCE IF NOT EXISTS anggaran_desa_id_anggaran_seq;
ALTER TABLE Anggaran_Desa ALTER COLUMN id_anggaran SET DEFAULT nextval('anggaran_desa_id_anggaran_seq'::regclass);
SELECT setval('anggaran_desa_id_anggaran_seq', COALESCE((SELECT MAX(id_anggaran) + 1 FROM Anggaran_Desa), 1), false);

-- PERBAIKAN UNTUK TABEL PROYEK_PEMBANGUNAN
CREATE SEQUENCE IF NOT EXISTS proyek_pembangunan_id_proyek_seq;
ALTER TABLE Proyek_Pembangunan ALTER COLUMN id_proyek SET DEFAULT nextval('proyek_pembangunan_id_proyek_seq'::regclass);
SELECT setval('proyek_pembangunan_id_proyek_seq', COALESCE((SELECT MAX(id_proyek) + 1 FROM Proyek_Pembangunan), 1), false);

-- MENJAMIN ADANYA KOLOM YANG DIBUTUHKAN
ALTER TABLE Proyek_Pembangunan ADD COLUMN IF NOT EXISTS anggaran_proyek DECIMAL(18, 2) DEFAULT 0.00;
ALTER TABLE Proyek_Pembangunan ADD COLUMN IF NOT EXISTS realisasi_anggaran DECIMAL(18, 2) DEFAULT 0.00;
ALTER TABLE Proyek_Pembangunan ADD COLUMN IF NOT EXISTS id_anggaran BIGINT;

-- MENAMBAHKAN FOREIGN KEY (JIKA BELUM ADA)
-- Ini akan menghubungkan setiap proyek dengan anggaran tahunannya.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'fk_proyek_ke_anggaran' AND conrelid = 'proyek_pembangunan'::regclass
    ) THEN
        ALTER TABLE Proyek_Pembangunan 
        ADD CONSTRAINT fk_proyek_ke_anggaran 
        FOREIGN KEY (id_anggaran) REFERENCES Anggaran_Desa(id_anggaran);
    END IF;
END;
$$;




CREATE OR REPLACE FUNCTION KelolaAnggaran(
    -- Parameter utama untuk menentukan aksi
    p_aksi VARCHAR, -- 'BUAT_TAHUNAN', 'ALOKASI_PROYEK', 'CATAT_REALISASI'
    
    -- Parameter untuk 'BUAT_TAHUNAN'
    p_tahun INT DEFAULT NULL,
    p_total_anggaran DECIMAL(18, 2) DEFAULT NULL,
    p_keterangan TEXT DEFAULT NULL,
    
    -- Parameter untuk 'ALOKASI_PROYEK' & 'CATAT_REALISASI'
    p_id_proyek BIGINT DEFAULT NULL,
    
    -- Parameter untuk 'ALOKASI_PROYEK'
    p_jumlah_alokasi DECIMAL(18, 2) DEFAULT NULL,
    
    -- Parameter untuk 'CATAT_REALISASI'
    p_jumlah_realisasi DECIMAL(18, 2) DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    v_id_anggaran BIGINT;
    v_total_anggaran_tahunan DECIMAL(18, 2);
    v_total_sudah_teralokasi DECIMAL(18, 2);
    v_sisa_anggaran DECIMAL(18, 2);
    v_alokasi_proyek DECIMAL(18, 2);
    v_total_realisasi_sebelumnya DECIMAL(18, 2);
BEGIN
    -- ==========================================================
    -- Blok Logika untuk Aksi 'BUAT_TAHUNAN'
    -- ==========================================================
    IF p_aksi = 'BUAT_TAHUNAN' THEN
        IF EXISTS (SELECT 1 FROM Anggaran_Desa WHERE tahun = p_tahun) THEN
            RETURN 'Gagal: Anggaran untuk tahun ' || p_tahun || ' sudah ada.';
        END IF;
        INSERT INTO Anggaran_Desa(tahun, total_anggaran, keterangan)
        VALUES (p_tahun, p_total_anggaran, p_keterangan);
        RETURN 'Sukses: Anggaran untuk tahun ' || p_tahun || ' berhasil ditambahkan.';

    -- ==========================================================
    -- Blok Logika untuk Aksi 'ALOKASI_PROYEK'
    -- ==========================================================
    ELSIF p_aksi = 'ALOKASI_PROYEK' THEN
        SELECT id_anggaran INTO v_id_anggaran FROM Proyek_Pembangunan WHERE id_proyek = p_id_proyek;
        IF v_id_anggaran IS NULL THEN RETURN 'Gagal: Proyek dengan ID ' || p_id_proyek || ' tidak ditemukan atau belum terhubung ke Anggaran Tahunan.'; END IF;
        
        SELECT total_anggaran INTO v_total_anggaran_tahunan FROM Anggaran_Desa WHERE id_anggaran = v_id_anggaran;
        SELECT COALESCE(SUM(anggaran_proyek), 0) INTO v_total_sudah_teralokasi FROM Proyek_Pembangunan WHERE id_anggaran = v_id_anggaran;
        v_sisa_anggaran := v_total_anggaran_tahunan - v_total_sudah_teralokasi;

        IF p_jumlah_alokasi > v_sisa_anggaran THEN
            RETURN 'Gagal: Alokasi sebesar ' || p_jumlah_alokasi || ' melebihi sisa anggaran (' || v_sisa_anggaran || ').';
        ELSE
            UPDATE Proyek_Pembangunan SET anggaran_proyek = anggaran_proyek + p_jumlah_alokasi WHERE id_proyek = p_id_proyek;
            RETURN 'Sukses: Dana sebesar ' || p_jumlah_alokasi || ' berhasil dialokasikan ke proyek ID ' || p_id_proyek;
        END IF;

    -- ==========================================================
    -- Blok Logika untuk Aksi 'CATAT_REALISASI'
    -- ==========================================================
    ELSIF p_aksi = 'CATAT_REALISASI' THEN
        SELECT anggaran_proyek, COALESCE(realisasi_anggaran, 0)
        INTO v_alokasi_proyek, v_total_realisasi_sebelumnya
        FROM Proyek_Pembangunan WHERE id_proyek = p_id_proyek;

        IF v_alokasi_proyek IS NULL THEN RETURN 'Gagal: Proyek dengan ID ' || p_id_proyek || ' tidak ditemukan.'; END IF;

        IF (v_total_realisasi_sebelumnya + p_jumlah_realisasi) > v_alokasi_proyek THEN
            RETURN 'Gagal: Realisasi akan membuat total melebihi alokasi dana proyek (' || v_alokasi_proyek || ').';
        END IF;
        
        UPDATE Proyek_Pembangunan SET realisasi_anggaran = realisasi_anggaran + p_jumlah_realisasi WHERE id_proyek = p_id_proyek;
        RETURN 'Sukses: Realisasi dana sebesar ' || p_jumlah_realisasi || ' untuk proyek ID ' || p_id_proyek || ' telah dicatat.';
        
    -- Jika aksi tidak valid
    ELSE
        RETURN 'Gagal: Aksi "' || p_aksi || '" tidak valid. Gunakan ''BUAT_TAHUNAN'', ''ALOKASI_PROYEK'', atau ''CATAT_REALISASI''.';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Gagal: Data Proyek atau Anggaran tidak ditemukan.';
END;
$$ LANGUAGE plpgsql;


-- Menguji pembuatan anggaran untuk tahun 2099 (agar tidak bentrok)
SELECT KelolaAnggaran(
    p_aksi           := 'BUAT_TAHUNAN', 
    p_tahun          := 2099, 
    p_total_anggaran := 1000000000.00, 
    p_keterangan     := 'Anggaran Tes Tahun 2099'
);


-- Cek apakah data tahun 2099 sudah masuk
SELECT * FROM Anggaran_Desa WHERE tahun = 2099;

-- Hapus data tes agar bisa dijalankan kembali (opsional)
DELETE FROM Anggaran_Desa WHERE tahun = 2099;

SELECT KelolaAnggaran(
    p_aksi           := 'ALOKASI_PROYEK', 
    p_id_proyek      := 1, 
    p_jumlah_alokasi := 50000000
);
SELECT id_proyek, anggaran_proyek FROM Proyek_Pembangunan WHERE id_proyek = 1;

SELECT KelolaAnggaran(
    p_aksi             := 'CATAT_REALISASI', 
    p_id_proyek        := 1, 
    p_jumlah_realisasi := 10000000
);
SELECT id_proyek, anggaran_proyek, realisasi_anggaran FROM Proyek_Pembangunan WHERE id_proyek = 1;


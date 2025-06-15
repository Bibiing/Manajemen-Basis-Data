CREATE SEQUENCE IF NOT EXISTS warga_id_warga_seq;
ALTER TABLE Warga
ALTER COLUMN id_warga SET DEFAULT nextval('warga_id_warga_seq'::regclass);
SELECT setval(
  'warga_id_warga_seq',
  COALESCE((SELECT MAX(id_warga) + 1 FROM Warga), 1),
  false
);

CREATE OR REPLACE FUNCTION KelolaWarga(
    p_aksi VARCHAR, -- Diisi 'CREATE', 'UPDATE', atau 'DELETE'
    p_nik CHAR(16),
    
    -- Parameter untuk Aksi 'CREATE'
    p_nama VARCHAR DEFAULT NULL,
    p_tanggal_lahir DATE DEFAULT NULL,
    p_jenis_kelamin VARCHAR DEFAULT NULL,
    p_id_keluarga BIGINT DEFAULT NULL,
    p_no_kk CHAR(16) DEFAULT NULL,
    p_alamat VARCHAR(255) DEFAULT NULL,
    
    -- Parameter untuk Aksi 'CREATE' dan 'UPDATE'
    p_status_perkawinan VARCHAR DEFAULT NULL,
    p_pendidikan_terakhir VARCHAR DEFAULT NULL,
    p_pekerjaan VARCHAR DEFAULT NULL,
    p_status_ekonomi VARCHAR DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    v_id_keluarga_warga BIGINT;
    v_sisa_anggota INT;
    v_new_id_keluarga BIGINT;
    v_new_id_warga BIGINT;
BEGIN
    -- =======================================================
    -- Blok Logika untuk Aksi 'CREATE' (dari RegistrasiWarga)
    -- =======================================================
    IF p_aksi = 'CREATE' THEN
        -- Validasi NIK belum ada
        IF EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RETURN 'Gagal CREATE: NIK ' || p_nik || ' sudah terdaftar.';
        END IF;

        -- Skenario Keluarga Baru
        IF p_id_keluarga IS NULL THEN
            IF EXISTS (SELECT 1 FROM Keluarga WHERE no_kk = p_no_kk) THEN
                RETURN 'Gagal CREATE: Nomor KK ' || p_no_kk || ' sudah terdaftar.';
            END IF;
            SELECT COALESCE(MAX(id_keluarga), 0) + 1 INTO v_new_id_keluarga FROM Keluarga;
            INSERT INTO Keluarga(id_keluarga, no_kk, alamat, jumlah_anggota) VALUES (v_new_id_keluarga, p_no_kk, p_alamat, 1);
            INSERT INTO Warga(nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
            VALUES (p_nik, p_nama, p_tanggal_lahir, p_jenis_kelamin, p_status_perkawinan, p_pendidikan_terakhir, p_pekerjaan, p_status_ekonomi, v_new_id_keluarga)
            RETURNING id_warga INTO v_new_id_warga;
            RETURN CONCAT('Sukses CREATE: Keluarga baru (ID: ', v_new_id_keluarga, ') dan warga baru (ID: ', v_new_id_warga, ') telah diregistrasi.');
        -- Skenario Keluarga Lama
        ELSE
            IF NOT EXISTS (SELECT 1 FROM Keluarga WHERE id_keluarga = p_id_keluarga) THEN
                RETURN 'Gagal CREATE: ID Keluarga ' || p_id_keluarga || ' tidak ditemukan.';
            END IF;
            INSERT INTO Warga(nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
            VALUES (p_nik, p_nama, p_tanggal_lahir, p_jenis_kelamin, p_status_perkawinan, p_pendidikan_terakhir, p_pekerjaan, p_status_ekonomi, p_id_keluarga)
            RETURNING id_warga INTO v_new_id_warga;
            UPDATE Keluarga SET jumlah_anggota = jumlah_anggota + 1 WHERE id_keluarga = p_id_keluarga;
            RETURN CONCAT('Sukses CREATE: Warga baru (ID: ', v_new_id_warga, ') berhasil ditambahkan ke keluarga ID ', p_id_keluarga, '.');
        END IF;

    -- ======================================================
    -- Blok Logika untuk Aksi 'UPDATE' (dari UpdateDataWarga)
    -- ======================================================
    ELSIF p_aksi = 'UPDATE' THEN
        IF NOT EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RETURN 'Gagal UPDATE: Warga dengan NIK ' || p_nik || ' tidak ditemukan.';
        END IF;
        UPDATE Warga
        SET
            status_perkawinan   = COALESCE(p_status_perkawinan, status_perkawinan),
            pendidikan_terakhir = COALESCE(p_pendidikan_terakhir, pendidikan_terakhir),
            pekerjaan           = COALESCE(p_pekerjaan, pekerjaan),
            status_ekonomi      = COALESCE(p_status_ekonomi, status_ekonomi)
        WHERE nik = p_nik;
        RETURN 'Sukses UPDATE: Data untuk warga dengan NIK ' || p_nik || ' telah diperbarui.';

    -- =====================================================
    -- Blok Logika untuk Aksi 'DELETE' (dari HapusWarga)
    -- =====================================================
    ELSIF p_aksi = 'DELETE' THEN
        SELECT id_keluarga INTO v_id_keluarga_warga FROM Warga WHERE nik = p_nik;
        IF v_id_keluarga_warga IS NULL THEN
            RETURN 'Gagal DELETE: Warga dengan NIK ' || p_nik || ' tidak ditemukan.';
        END IF;
        DELETE FROM Warga WHERE nik = p_nik;
        UPDATE Keluarga SET jumlah_anggota = jumlah_anggota - 1
        WHERE id_keluarga = v_id_keluarga_warga
        RETURNING jumlah_anggota INTO v_sisa_anggota;
        IF v_sisa_anggota = 0 THEN
            DELETE FROM Keluarga WHERE id_keluarga = v_id_keluarga_warga;
            RETURN 'Sukses DELETE: Warga NIK ' || p_nik || ' dan data keluarganya telah dihapus.';
        END IF;
        RETURN 'Sukses DELETE: Warga dengan NIK ' || p_nik || ' telah dihapus.';
        
    -- Jika aksi tidak valid
    ELSE
        RETURN 'Gagal: Aksi "' || p_aksi || '" tidak valid. Gunakan ''CREATE'', ''UPDATE'', atau ''DELETE''.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Membuat keluarga baru untuk 'Adi Saputra'
SELECT KelolaWarga(
    p_aksi               := 'CREATE',
    p_nik                := '3578010101900005',
    p_nama               := 'Adi Saputra',
    p_tanggal_lahir      := '1990-01-01',
    p_jenis_kelamin      := 'Laki-laki',
    p_status_perkawinan  := 'Kawin',
    p_pendidikan_terakhir:= 'S1',
    p_pekerjaan          := 'Karyawan Swasta',
    p_status_ekonomi     := 'Mampu',
    p_id_keluarga        := NULL, 
    p_no_kk              := '3578010101900005',
    p_alamat             := 'Jl. Pahlawan No. 10'
);

SELECT * FROM Warga WHERE nik = '3578010101900005';

-- Mengubah data pekerjaan Adi Saputra
SELECT KelolaWarga(
    p_aksi          := 'UPDATE',
    p_nik           := '3578010101900005',
    p_pekerjaan     := 'Wiraswasta'
);

SELECT pekerjaan FROM Warga WHERE nik = '3578010101900005';

-- Menghapus data Adi Saputra
SELECT KelolaWarga(
    p_aksi          := 'DELETE',
    p_nik           := '3578010101900005'
);

SELECT * FROM Warga WHERE nik = '3578010101900005';

SELECT * FROM Keluarga WHERE no_kk = '3578010101900005';
CREATE OR REPLACE PROCEDURE KelolaWarga(
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
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_keluarga_warga BIGINT;
    v_sisa_anggota INT;
    v_new_id_keluarga BIGINT;
    v_new_id_warga BIGINT;
BEGIN
    IF p_aksi = 'CREATE' THEN
        IF EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RAISE NOTICE 'Gagal CREATE: NIK % sudah terdaftar.', p_nik;
            RETURN;
        END IF;

        IF p_id_keluarga IS NULL THEN
            IF EXISTS (SELECT 1 FROM Keluarga WHERE no_kk = p_no_kk) THEN
                RAISE NOTICE 'Gagal CREATE: Nomor KK % sudah terdaftar.', p_no_kk;
                RETURN;
            END IF;
            SELECT COALESCE(MAX(id_keluarga), 0) + 1 INTO v_new_id_keluarga FROM Keluarga;
            INSERT INTO Keluarga(id_keluarga, no_kk, alamat, jumlah_anggota) 
            VALUES (v_new_id_keluarga, p_no_kk, p_alamat, 1);

            INSERT INTO Warga(
                nik, nama, tanggal_lahir, jenis_kelamin, 
                status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga
            )
            VALUES (
                p_nik, p_nama, p_tanggal_lahir, p_jenis_kelamin, 
                p_status_perkawinan, p_pendidikan_terakhir, p_pekerjaan, p_status_ekonomi, v_new_id_keluarga
            )
            RETURNING id_warga INTO v_new_id_warga;

            RAISE NOTICE 'Sukses CREATE: Keluarga baru (ID: %) dan warga baru (ID: %) telah diregistrasi.', v_new_id_keluarga, v_new_id_warga;

        ELSE
            IF NOT EXISTS (SELECT 1 FROM Keluarga WHERE id_keluarga = p_id_keluarga) THEN
                RAISE NOTICE 'Gagal CREATE: ID Keluarga % tidak ditemukan.', p_id_keluarga;
                RETURN;
            END IF;

            INSERT INTO Warga(
                nik, nama, tanggal_lahir, jenis_kelamin, 
                status_perkawinan, pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga
            )
            VALUES (
                p_nik, p_nama, p_tanggal_lahir, p_jenis_kelamin, 
                p_status_perkawinan, p_pendidikan_terakhir, p_pekerjaan, p_status_ekonomi, p_id_keluarga
            )
            RETURNING id_warga INTO v_new_id_warga;

            UPDATE Keluarga SET jumlah_anggota = jumlah_anggota + 1 WHERE id_keluarga = p_id_keluarga;

            RAISE NOTICE 'Sukses CREATE: Warga baru (ID: %) berhasil ditambahkan ke keluarga ID %.', v_new_id_warga, p_id_keluarga;
        END IF;

    ELSIF p_aksi = 'UPDATE' THEN
        IF NOT EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RAISE NOTICE 'Gagal UPDATE: Warga dengan NIK % tidak ditemukan.', p_nik;
            RETURN;
        END IF;

        UPDATE Warga
        SET
            status_perkawinan   = COALESCE(p_status_perkawinan, status_perkawinan),
            pendidikan_terakhir = COALESCE(p_pendidikan_terakhir, pendidikan_terakhir),
            pekerjaan           = COALESCE(p_pekerjaan, pekerjaan),
            status_ekonomi      = COALESCE(p_status_ekonomi, status_ekonomi)
        WHERE nik = p_nik;

        RAISE NOTICE 'Sukses UPDATE: Data untuk warga dengan NIK % telah diperbarui.', p_nik;

    ELSIF p_aksi = 'DELETE' THEN
        SELECT id_keluarga INTO v_id_keluarga_warga FROM Warga WHERE nik = p_nik;
        IF v_id_keluarga_warga IS NULL THEN
            RAISE NOTICE 'Gagal DELETE: Warga dengan NIK % tidak ditemukan.', p_nik;
            RETURN;
        END IF;

        DELETE FROM Warga WHERE nik = p_nik;
        UPDATE Keluarga SET jumlah_anggota = jumlah_anggota - 1
        WHERE id_keluarga = v_id_keluarga_warga
        RETURNING jumlah_anggota INTO v_sisa_anggota;

        IF v_sisa_anggota = 0 THEN
            DELETE FROM Keluarga WHERE id_keluarga = v_id_keluarga_warga;
            RAISE NOTICE 'Sukses DELETE: Warga NIK % dan data keluarganya telah dihapus.', p_nik;
        ELSE
            RAISE NOTICE 'Sukses DELETE: Warga dengan NIK % telah dihapus.', p_nik;
        END IF;

    ELSE
        RAISE NOTICE 'Gagal: Aksi "%" tidak valid. Gunakan ''CREATE'', ''UPDATE'', atau ''DELETE''.', p_aksi;
        RETURN;
    END IF;
END;
$$;

----warga baru + keluarga baru----
CALL KelolaWarga(
    'CREATE',
    '6210123456780001',           
    'Udin Saputra',             
    '2000-01-01',                
    'Laki-laki',                  
    NULL,                         
    '1234567890123456',            
    'Jl. Merdeka No.1',          
    'Belum Kawin',                  
    'SMA',                         
    'Pelajar',                      
    'Menengah'                      
);

----warga baru + keluarga sudah ada----
CALL KelolaWarga(
    'CREATE',
    '9210123456780002',
    'Budi Santoso',
    '1995-05-05',
    'Laki-laki',
    100002,                             
    NULL,                           
    NULL,                           
    'Menikah',
    'S1',
    'Pegawai Negeri',
    'Menengah'
);

----Update Data----
CALL KelolaWarga(
    'UPDATE',
    '6210123456780001',    
    NULL, NULL, NULL, NULL, NULL, NULL, 
    NULL,                               
    'S2',                               
    'Dosen',                             
    NULL                                 
);

----Delete Data----
CALL KelolaWarga(
    'DELETE',
    '9210123456780002'    
);


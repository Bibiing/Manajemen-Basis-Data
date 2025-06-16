CREATE OR REPLACE PROCEDURE kelola_warga(
    p_aksi VARCHAR,             
    p_nik CHAR(16),
    p_nama VARCHAR DEFAULT NULL,
    p_tanggal_lahir DATE DEFAULT NULL,
    p_jenis_kelamin VARCHAR DEFAULT NULL,
    p_id_keluarga BIGINT DEFAULT NULL,
    p_no_kk CHAR(16) DEFAULT NULL,
    p_alamat VARCHAR(255) DEFAULT NULL,
    p_status_perkawinan VARCHAR DEFAULT NULL,
    p_pendidikan_terakhir VARCHAR DEFAULT NULL,
    p_pekerjaan VARCHAR DEFAULT NULL,
    p_status_ekonomi VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_keluarga BIGINT;
    v_sisa_anggota INT;
    v_new_id_keluarga BIGINT;
    v_id_warga BIGINT;
BEGIN
    IF p_aksi = 'CREATE' THEN
        IF EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RAISE NOTICE 'NIK % sudah terdaftar.', p_nik;
            RETURN;
        END IF;

        -- Jika ID keluarga belum ada, buat keluarga baru
        IF p_id_keluarga IS NULL THEN
            IF EXISTS (SELECT 1 FROM Keluarga WHERE no_kk = p_no_kk) THEN
                RAISE NOTICE 'Nomor KK % sudah terdaftar.', p_no_kk;
                RETURN;
            END IF;
            SELECT COALESCE(MAX(id_keluarga), 0) + 1 INTO v_new_id_keluarga FROM Keluarga;
            INSERT INTO Keluarga(id_keluarga, no_kk, alamat, jumlah_anggota)
            VALUES (v_new_id_keluarga, p_no_kk, p_alamat, 1);
            v_id_keluarga := v_new_id_keluarga;
        ELSE
            SELECT id_keluarga INTO v_id_keluarga FROM Keluarga WHERE id_keluarga = p_id_keluarga;
            IF NOT FOUND THEN
                RAISE NOTICE 'ID Keluarga % tidak ditemukan.', p_id_keluarga;
                RETURN;
            END IF;
            UPDATE Keluarga SET jumlah_anggota = jumlah_anggota + 1 WHERE id_keluarga = v_id_keluarga;
        END IF;

        INSERT INTO Warga(nik, nama, tanggal_lahir, jenis_kelamin, status_perkawinan,
                          pendidikan_terakhir, pekerjaan, status_ekonomi, id_keluarga)
        VALUES (p_nik, p_nama, p_tanggal_lahir, p_jenis_kelamin, p_status_perkawinan,
                p_pendidikan_terakhir, p_pekerjaan, p_status_ekonomi, v_id_keluarga)
        RETURNING id_warga INTO v_id_warga;

        RAISE NOTICE 'Warga baru (ID: %) berhasil ditambahkan.', v_id_warga;

    ELSIF p_aksi = 'UPDATE' THEN
        IF NOT EXISTS (SELECT 1 FROM Warga WHERE nik = p_nik) THEN
            RAISE NOTICE 'Warga dengan NIK % tidak ditemukan.', p_nik;
            RETURN;
        END IF;
        UPDATE Warga
        SET
            status_perkawinan   = COALESCE(p_status_perkawinan, status_perkawinan),
            pendidikan_terakhir = COALESCE(p_pendidikan_terakhir, pendidikan_terakhir),
            pekerjaan           = COALESCE(p_pekerjaan, pekerjaan),
            status_ekonomi      = COALESCE(p_status_ekonomi, status_ekonomi)
        WHERE nik = p_nik;
        RAISE NOTICE 'Data warga dengan NIK % berhasil diperbarui.', p_nik;

    ELSIF p_aksi = 'DELETE' THEN
        SELECT id_keluarga INTO v_id_keluarga FROM Warga WHERE nik = p_nik;
        IF NOT FOUND THEN
            RAISE NOTICE 'Warga dengan NIK % tidak ditemukan.', p_nik;
            RETURN;
        END IF;
        DELETE FROM Warga WHERE nik = p_nik;
        UPDATE Keluarga SET jumlah_anggota = jumlah_anggota - 1
        WHERE id_keluarga = v_id_keluarga RETURNING jumlah_anggota INTO v_sisa_anggota;

        IF v_sisa_anggota = 0 THEN
            DELETE FROM Keluarga WHERE id_keluarga = v_id_keluarga;
            RAISE NOTICE 'Warga dan keluarganya telah dihapus karena tidak ada anggota tersisa.';
        ELSE
            RAISE NOTICE 'Warga dengan NIK % telah dihapus.', p_nik;
        END IF;
    ELSE
        RAISE NOTICE 'Aksi % tidak dikenali. Gunakan CREATE, UPDATE, atau DELETE.', p_aksi;
    END IF;
END;
$$;

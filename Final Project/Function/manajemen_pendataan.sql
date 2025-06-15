-- No 5 poin B
-- Fungsi untuk mengupdate data warga (No KK, pendidikan terakhir, pekerjaan, dan status ekonomi)
CREATE OR REPLACE FUNCTION update_data_warga(
    p_nik CHAR(16),
    p_no_kk CHAR(16),
    p_pendidikan VARCHAR,
    p_pekerjaan VARCHAR,
    p_status_ekonomi VARCHAR
)
RETURNS TEXT AS $$
DECLARE
    v_id_keluarga BIGINT;
BEGIN
    -- Ambil ID Keluarga berdasarkan No_KK
    SELECT id_keluarga INTO v_id_keluarga
    FROM Keluarga
    WHERE no_kk = p_no_kk;

    IF v_id_keluarga IS NULL THEN
        RETURN 'GAGAL: No KK tujuan tidak ditemukan. Data tidak diperbarui.';
    END IF;

    -- Update data Warga
    UPDATE Warga
    SET
        id_keluarga = v_id_keluarga,
        pendidikan_terakhir = p_pendidikan,
        pekerjaan = p_pekerjaan,
        status_ekonomi = p_status_ekonomi
    WHERE nik = p_nik;

    -- Cek jika ada baris yang terpengaruh
    IF FOUND THEN
        RETURN 'SUKSES: Data warga berhasil diperbarui.';
    ELSE
        RETURN 'GAGAL: NIK tidak ditemukan. Data tidak diperbarui.';
    END IF;
END;
$$ LANGUAGE plpgsql;

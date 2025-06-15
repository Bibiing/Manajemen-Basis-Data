-- Fungsi untuk mengelola anggaran desa (mendata rencana pembangunan desa selama anggaran masih tercukupi)
CREATE OR REPLACE FUNCTION tambah_rencana_anggaran(
    p_id_anggaran_tahunan BIGINT,
    p_id_proyek BIGINT,
    p_nama_kegiatan VARCHAR,
    p_kategori VARCHAR,
    p_pagu_anggaran NUMERIC,
    p_tanggal_alokasi DATE
)
RETURNS TEXT AS $$
DECLARE
    v_total_anggaran_tahunan NUMERIC;
    v_total_teralokasi NUMERIC;
BEGIN
    -- Ambil total anggaran tahun tersebut
    SELECT total_anggaran INTO v_total_anggaran_tahunan
    FROM Anggaran_Desa
    WHERE id_anggaran = p_id_anggaran_tahunan;

    IF v_total_anggaran_tahunan IS NULL THEN
        RETURN 'GAGAL: ID Anggaran Tahunan tidak ditemukan.';
    END IF;

    -- Hitung total dana yang sudah dialokasikan sebelumnya
    SELECT COALESCE(SUM(pagu_anggaran), 0)
    INTO v_total_teralokasi
    FROM Sumber_Dana
    WHERE id_anggaran_tahunan = p_id_anggaran_tahunan;

    -- Cek apakah penambahan pagu ini melebihi total anggaran tahunan
    IF v_total_teralokasi + p_pagu_anggaran > v_total_anggaran_tahunan THEN
        RETURN 'GAGAL: Alokasi gagal karena akan melebihi total anggaran tahunan!';
    END IF;

    -- Masukkan rincian kegiatan
    INSERT INTO Sumber_Dana (
        id_anggaran_tahunan, id_proyek, nama_kegiatan, kategori, pagu_anggaran, tanggal_alokasi
    ) VALUES (
        p_id_anggaran_tahunan, p_id_proyek, p_nama_kegiatan, p_kategori, p_pagu_anggaran, p_tanggal_alokasi
    );

    RETURN 'Berhasil: Kegiatan telah ditambahkan ke dalam perencanaan anggaran.';
END;
$$ LANGUAGE plpgsql;

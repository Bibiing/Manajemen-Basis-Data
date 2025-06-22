-- no 5 Poin D
-- Fungsi untuk mengelola progres pengerjaan proyek
CREATE OR REPLACE FUNCTION lacak_kemajuan_proyek(p_id_proyek BIGINT)
RETURNS TABLE (
    nama_proyek VARCHAR,
    status_proyek VARCHAR,
    persentase_progress DECIMAL(5, 2),
    total_anggaran NUMERIC,
    total_realisasi_belanja NUMERIC,
    sisa_anggaran NUMERIC,
    tanggal_mulai DATE,
    tanggal_selesai DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.nama_proyek,
        p.status_proyek,
        p.persentase_progress,

        -- SUM dari total_anggaran
        COALESCE((
            SELECT SUM(ad.total_anggaran)
            FROM Anggaran_Desa ad
            JOIN Rincian_Anggaran ra1 ON ra1.id_anggaran = ad.id_anggaran
            WHERE ra1.id_proyek = p.id_proyek
        ), 0) AS total_anggaran,

        -- SUM dari jumlah_dana
        COALESCE((
            SELECT SUM(ra2.jumlah_dana)
            FROM Rincian_Anggaran ra2
            WHERE ra2.id_proyek = p.id_proyek
        ), 0) AS total_realisasi_belanja,

        -- Sisa anggaran = total  anggaran - realisasi
        COALESCE((
            SELECT SUM(ad.total_anggaran)
            FROM Anggaran_Desa ad
            JOIN Rincian_Anggaran ra1 ON ra1.id_anggaran = ad.id_anggaran
            WHERE ra1.id_proyek = p.id_proyek
        ), 0)
        -
        COALESCE((
            SELECT SUM(ra2.jumlah_dana)
            FROM Rincian_Anggaran ra2
            WHERE ra2.id_proyek = p.id_proyek
        ), 0) AS sisa_anggaran,

        p.tanggal_mulai,
        p.tanggal_selesai

    FROM 
        Proyek_Pembangunan p
    WHERE 
        p.id_proyek = p_id_proyek;
END;
$$ LANGUAGE plpgsql;

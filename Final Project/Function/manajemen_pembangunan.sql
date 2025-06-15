-- no 5 Poin D
-- Fungsi untuk mengelola progres pengerjaan proyek
CREATE OR REPLACE FUNCTION lacak_kemajuan_proyek(p_id_proyek BIGINT)
RETURNS TABLE (
    nama_proyek VARCHAR,
    status_proyek VARCHAR,
    persentase_progress DECIMAL(5, 2),
    total_pagu_anggaran NUMERIC,
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
        -- Menghitung total pagu dari semua sumber dana untuk proyek ini
        COALESCE((SELECT SUM(sd.pagu_anggaran) FROM Sumber_Dana sd WHERE sd.id_proyek = p.id_proyek), 0) AS total_pagu_anggaran,
        -- Menghitung total belanja dari semua transaksi terkait
        COALESCE((SELECT SUM(tr.jumlah_belanja) 
                  FROM Transaksi_Realisasi tr 
                  JOIN Sumber_Dana s_inner ON tr.id_sumber_dana = s_inner.id_sumber_dana
                  WHERE s_inner.id_proyek = p.id_proyek), 0) AS total_realisasi_belanja,
        -- Menghitung sisa dana
        COALESCE((SELECT SUM(sd.pagu_anggaran) FROM Sumber_Dana sd WHERE sd.id_proyek = p.id_proyek), 0) - 
        COALESCE((SELECT SUM(tr.jumlah_belanja) 
                  FROM Transaksi_Realisasi tr 
                  JOIN Sumber_Dana s_inner ON tr.id_sumber_dana = s_inner.id_sumber_dana
                  WHERE s_inner.id_proyek = p.id_proyek), 0) AS sisa_anggaran,
        p.tanggal_mulai,
        p.tanggal_selesai
    FROM 
        Proyek_Pembangunan p
    WHERE 
        p.id_proyek = p_id_proyek;
END;
$$ LANGUAGE plpgsql;

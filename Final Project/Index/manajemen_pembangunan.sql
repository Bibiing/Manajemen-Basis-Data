EXPLAIN ANALYZE
SELECT 
    pp.nama_proyek,
    pp.status_proyek,
    COALESCE(SUM(tr.jumlah_belanja), 0) AS total_penggunaan_dana
FROM 
    Proyek_Pembangunan pp
LEFT JOIN 
    Sumber_Dana sd ON pp.id_proyek = sd.id_proyek
LEFT JOIN 
    Transaksi_Realisasi tr ON sd.id_sumber_dana = tr.id_sumber_dana
GROUP BY 
    pp.id_proyek, pp.nama_proyek, pp.status_proyek 
ORDER BY 
    total_penggunaan_dana DESC;


CREATE INDEX idx_sumber_dana_proyek ON Sumber_Dana(id_proyek);
CREATE INDEX idx_transaksi_sumber_dana ON Transaksi_Realisasi(id_sumber_dana);

-------------------------------------------------------------------------------

explain analyze
SELECT 
    nama_proyek,
    status_proyek,
    persentase_progress,
    tanggal_mulai,
    tanggal_selesai,
    (tanggal_selesai - tanggal_mulai) AS durasi_hari
FROM 
    Proyek_Pembangunan
ORDER BY 
    CASE 
        WHEN status_proyek = 'Berjalan' THEN 1
        WHEN status_proyek = 'Direncanakan' THEN 2
        WHEN status_proyek = 'Selesai' THEN 3
        ELSE 4
    END, persentase_progress DESC;

CREATE INDEX idx_proyek_status_progress ON Proyek_Pembangunan(status_proyek, persentase_progress DESC);


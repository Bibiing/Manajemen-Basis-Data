EXPLAIN ANALYZE
SELECT 
    ps.id_permohonan,
    w.nama,
    js.nama_surat, 
    ps.tanggal_permohonan,
    ps.catatan 
FROM 
    Permohonan_Surat ps
JOIN 
    Warga w ON ps.id_warga = w.id_warga
JOIN
    Jenis_Surat js ON ps.id_jenis = js.id_jenis
WHERE 
    ps.status_permohonan = 'Ditolak'
ORDER BY 
    ps.tanggal_permohonan DESC;

CREATE INDEX idx_status_surat ON permohonan_surat (status_permohonan);

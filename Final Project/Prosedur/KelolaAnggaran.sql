CREATE OR REPLACE PROCEDURE kelola_anggaran(p_tahun INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_anggaran NUMERIC(18,2);
    v_total_realisasi NUMERIC(18,2);
    v_sisa_anggaran NUMERIC(18,2);
    v_penggunaan RECORD;
BEGIN
    -- Ambil total anggaran tahun berjalan
    SELECT total_anggaran INTO v_total_anggaran
    FROM anggaran_desa
    WHERE tahun = p_tahun;

    IF NOT FOUND THEN
        RAISE NOTICE 'Tidak ada data anggaran untuk tahun %', p_tahun;
        RETURN;
    END IF;

    -- Hitung total realisasi penggunaan dana
    SELECT COALESCE(SUM(jumlah_dana), 0) INTO v_total_realisasi
    FROM rincian_anggaran
    WHERE EXTRACT(YEAR FROM tanggal_transaksi) = p_tahun;

    v_sisa_anggaran := v_total_anggaran - v_total_realisasi;

    RAISE NOTICE '--- Laporan Anggaran Desa Tahun % ---', p_tahun;
    RAISE NOTICE 'Total Anggaran       : Rp %', TO_CHAR(v_total_anggaran, 'FM999G999G999G999G999G990.00');
    RAISE NOTICE 'Total Realisasi Dana : Rp %', TO_CHAR(v_total_realisasi, 'FM999G999G999G999G999G990.00');
    RAISE NOTICE 'Sisa Anggaran        : Rp %', TO_CHAR(v_sisa_anggaran, 'FM999G999G999G990.00');

    IF v_total_realisasi > v_total_anggaran THEN
        RAISE NOTICE 'Peringatan: Penggunaan dana melebihi anggaran tahun %!', p_tahun;
    END IF;

    -- Transparansi: tampilkan alokasi dana per proyek
    RAISE NOTICE '--- Rincian Penggunaan Dana per Proyek ---';
    FOR v_penggunaan IN
        SELECT p.id_proyek, p.nama_proyek,
               COALESCE(SUM(r.jumlah_dana), 0) AS dana_terpakai
        FROM proyek_pembangunan p
        LEFT JOIN rincian_anggaran r ON p.id_proyek = r.id_proyek
        WHERE EXTRACT(YEAR FROM r.tanggal_transaksi) = p_tahun
        GROUP BY p.id_proyek, p.nama_proyek
        ORDER BY dana_terpakai DESC
    LOOP
        RAISE NOTICE 'Proyek: % | Dana Terpakai: Rp %', v_penggunaan.nama_proyek,
                     TO_CHAR(v_penggunaan.dana_terpakai, 'FM999G999G999G990.00');
    END LOOP;

    RAISE NOTICE '--------------------------------------------';
END;
$$;

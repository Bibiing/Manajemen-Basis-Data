CREATE OR REPLACE PROCEDURE kelola_proyek(p_id_proyek BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nama_proyek TEXT;
    v_status TEXT;
    v_mulai DATE;
    v_selesai DATE;
    v_progress NUMERIC(5,2);
    v_durasi_berjalan INTEGER;
    v_durasi_total INTEGER;
    v_total_dana NUMERIC(18,2);
    v_anggaran_tahunan NUMERIC(18,2);
    v_tahun INTEGER;
BEGIN
    SELECT nama_proyek, status_proyek, tanggal_mulai, tanggal_selesai, persentase_progress
    INTO v_nama_proyek, v_status, v_mulai, v_selesai, v_progress
    FROM proyek_pembangunan
    WHERE id_proyek = p_id_proyek;

    IF NOT FOUND THEN
        RAISE NOTICE 'Proyek dengan ID % tidak ditemukan.', p_id_proyek;
        RETURN;
    END IF;

    v_tahun := EXTRACT(YEAR FROM v_mulai);
    SELECT total_anggaran INTO v_anggaran_tahunan
    FROM anggaran_desa
    WHERE tahun = v_tahun;

    SELECT COALESCE(SUM(jumlah_dana), 0) INTO v_total_dana
    FROM rincian_anggaran
    WHERE id_proyek = p_id_proyek;

    RAISE NOTICE '--- Laporan Proyek ID % ---', p_id_proyek;
    RAISE NOTICE 'Nama Proyek          : %', v_nama_proyek;
    RAISE NOTICE 'Status Proyek        : %', v_status;
    RAISE NOTICE 'Tanggal Mulai        : %', v_mulai;

    IF v_status = 'Direncanakan' THEN
        RAISE NOTICE 'Tanggal Selesai      : Belum Ditentukan';
        RAISE NOTICE 'Progress Saat Ini    : % %%', TO_CHAR(v_progress, 'FM990.00');
        RAISE NOTICE 'Total Dana Dibutuhkan: Rp %', TO_CHAR(v_total_dana, 'FM999G999G999G990.00');

        IF v_total_dana > v_anggaran_tahunan THEN
            RAISE NOTICE 'Peringatan: Melebihi anggaran tahun % (Rp %)', v_tahun, TO_CHAR(v_anggaran_tahunan, 'FM999G999G999G990.00');
        END IF;

    ELSIF v_status = 'Berjalan' THEN
        RAISE NOTICE 'Tanggal Selesai      : Belum Ditentukan';
        RAISE NOTICE 'Progress Saat Ini    : % %%', TO_CHAR(v_progress, 'FM990.00');

        IF v_mulai <= CURRENT_DATE THEN
            v_durasi_berjalan := CURRENT_DATE - v_mulai;
            RAISE NOTICE 'Durasi Berjalan      : % hari (belum diketahui durasi total)', v_durasi_berjalan;
        ELSE
            RAISE NOTICE 'Durasi Berjalan      : Belum dimulai';
        END IF;

        RAISE NOTICE 'Total Dana Terpakai  : Rp %', TO_CHAR(v_total_dana, 'FM999G999G999G990.00');

        IF v_total_dana > v_anggaran_tahunan THEN
            RAISE NOTICE 'Peringatan: Pengeluaran melebihi anggaran tahun % (Rp %)', v_tahun, TO_CHAR(v_anggaran_tahunan, 'FM999G999G999G990.00');
        END IF;

    ELSIF v_status = 'Selesai' THEN
        RAISE NOTICE 'Tanggal Selesai      : %', v_selesai;
        RAISE NOTICE 'Progress Saat Ini    : % %%', TO_CHAR(v_progress, 'FM990.00');

        IF v_mulai IS NOT NULL AND v_selesai IS NOT NULL THEN
            v_durasi_total := v_selesai - v_mulai;
            RAISE NOTICE 'Durasi Total         : % hari', v_durasi_total;
        ELSE
            RAISE NOTICE 'Durasi Total         : Tidak tersedia';
        END IF;

        RAISE NOTICE 'Total Dana Terpakai  : Rp %', TO_CHAR(v_total_dana, 'FM999G999G999G990.00');

        IF v_total_dana > v_anggaran_tahunan THEN
            RAISE NOTICE 'Peringatan: Pengeluaran melebihi anggaran tahun % (Rp %)', v_tahun, TO_CHAR(v_anggaran_tahunan, 'FM999G999G999G990.00');
        END IF;

    ELSE
        RAISE NOTICE 'Status proyek tidak dikenali: %', v_status;
    END IF;

    RAISE NOTICE '----------------------------------------------';
END;
$$;

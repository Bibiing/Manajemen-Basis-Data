CREATE OR REPLACE FUNCTION fn_cegah_overbudget()
RETURNS TRIGGER AS $$
DECLARE
    pagu_tersedia DECIMAL(18, 2);
    total_belanja_sebelumnya DECIMAL(18, 2);
BEGIN
    -- 1. Ambil nilai pagu anggaran dari tabel Sumber_Dana
    SELECT pagu_anggaran INTO pagu_tersedia
    FROM Sumber_Dana 
    WHERE id_sumber_dana = NEW.id_sumber_dana;

    -- 2. Hitung total belanja yang sudah terjadi untuk sumber dana ini
    SELECT COALESCE(SUM(jumlah_belanja), 0) INTO total_belanja_sebelumnya
    FROM Transaksi_Realisasi
    WHERE id_sumber_dana = NEW.id_sumber_dana;

    -- 3. Cek apakah transaksi baru akan melebihi pagu
    IF (total_belanja_sebelumnya + NEW.jumlah_belanja) > pagu_tersedia THEN
        -- Jika ya, gagalkan operasi INSERT dengan memberikan pesan error
        RAISE EXCEPTION 'TRANSAKSI DITOLAK: Total belanja akan melebihi pagu anggaran yang ditetapkan!';
    END IF;

    -- Kembalikan baris baru agar operasi INSERT dapat dilanjutkan
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cegah_overbudget
BEFORE INSERT ON Transaksi_Realisasi
FOR EACH ROW
EXECUTE FUNCTION fn_cegah_overbudget();

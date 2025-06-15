-- No 4 Poin B atau A?
-- Langkah 1: Buat fungsi trigger
CREATE OR REPLACE FUNCTION fn_auto_timestamp_surat()
RETURNS TRIGGER AS $$
BEGIN
    -- Hanya jalankan logika jika kolom status benar-benar berubah
    IF OLD.status_permohonan IS DISTINCT FROM NEW.status_permohonan THEN
    
        -- Jika status berubah menjadi 'Diverifikasi' dan tanggal verifikasi masih kosong
        IF NEW.status_permohonan = 'Diverifikasi' AND NEW.tanggal_verifikasi IS NULL THEN
            NEW.tanggal_verifikasi := NOW();
        END IF;

        -- Jika status berubah menjadi 'Selesai' dan tanggal selesai masih kosong
        IF NEW.status_permohonan = 'Selesai' AND NEW.tanggal_selesai_diproses IS NULL THEN
            -- Pastikan tanggal verifikasi juga terisi jika terlewat
            IF NEW.tanggal_verifikasi IS NULL THEN
                NEW.tanggal_verifikasi := NOW();
            END IF;
            NEW.tanggal_selesai_diproses := NOW();
        END IF;
        
        -- Jika status berubah menjadi 'Sudah Diambil'
        IF NEW.status_permohonan = 'Sudah Diambil' AND NEW.tanggal_diambil_warga IS NULL THEN
            NEW.tanggal_diambil_warga := NOW();
        END IF;

    END IF;

    -- Kembalikan baris baru agar operasi UPDATE dapat dilanjutkan
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Langkah 2: Lampirkan fungsi ke tabel sebagai trigger
CREATE TRIGGER trg_auto_timestamp_surat
BEFORE UPDATE ON Permohonan_Surat
FOR EACH ROW
EXECUTE FUNCTION fn_auto_timestamp_surat();

-- No 4 Poin D
CREATE OR REPLACE FUNCTION fn_update_status_proyek()
RETURNS TRIGGER AS $$
BEGIN
    -- Hanya jalankan jika nilai persentase_progress diubah
    IF OLD.persentase_progress IS DISTINCT FROM NEW.persentase_progress THEN

        -- Jika progress mencapai 100, ubah status menjadi 'Selesai'
        IF NEW.persentase_progress >= 100 THEN
            NEW.status_proyek := 'Selesai';
            NEW.persentase_progress := 100; -- Pastikan tidak lebih dari 100

            -- Jika tanggal selesai belum diisi, isi dengan tanggal hari ini
            IF NEW.tanggal_selesai IS NULL THEN
                NEW.tanggal_selesai := CURRENT_DATE;
            END IF;
            
        -- Jika progress lebih dari 0 tapi kurang dari 100, statusnya 'Berjalan'
        ELSEIF NEW.persentase_progress > 0 THEN
            NEW.status_proyek := 'Berjalan';

        -- Jika progress diatur kembali ke 0
        ELSE
            NEW.status_proyek := 'Direncanakan';
        END IF;
    END IF;
    
    -- Kembalikan baris baru agar operasi UPDATE dapat dilanjutkan
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_status_proyek
BEFORE UPDATE ON Proyek_Pembangunan
FOR EACH ROW
EXECUTE FUNCTION fn_update_status_proyek();

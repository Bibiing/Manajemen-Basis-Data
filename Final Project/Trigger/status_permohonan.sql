-- Trigger Function
-- Point B
CREATE OR REPLACE FUNCTION fn_update_jumlah_anggota()
RETURNS TRIGGER AS $$
BEGIN
    -- Jika operasi adalah INSERT (warga baru)
    IF (TG_OP = 'INSERT') THEN
        UPDATE Keluarga
        SET jumlah_anggota = jumlah_anggota + 1
        WHERE id_keluarga = NEW.id_keluarga;
    
    -- Jika operasi adalah DELETE (warga dihapus)
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE Keluarga
        SET jumlah_anggota = jumlah_anggota - 1
        WHERE id_keluarga = OLD.id_keluarga;

    -- Jika operasi adalah UPDATE dan id_keluarga berubah (pindah KK)
    ELSIF (TG_OP = 'UPDATE' AND NEW.id_keluarga IS DISTINCT FROM OLD.id_keluarga) THEN
        -- Kurangi jumlah di keluarga lama
        UPDATE Keluarga
        SET jumlah_anggota = jumlah_anggota - 1
        WHERE id_keluarga = OLD.id_keluarga;
        
        -- Tambah jumlah di keluarga baru
        UPDATE Keluarga
        SET jumlah_anggota = jumlah_anggota + 1
        WHERE id_keluarga = NEW.id_keluarga;
    END IF;

    -- Kembalikan baris yang sesuai dengan operasi
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Lampirkan fungsi ke tabel Warga sebagai trigger
CREATE TRIGGER trg_update_jumlah_anggota
AFTER INSERT OR DELETE OR UPDATE ON Warga
FOR EACH ROW
EXECUTE FUNCTION fn_update_jumlah_anggota();

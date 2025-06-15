CREATE OR REPLACE FUNCTION KelolaProyek(
    -- Parameter utama untuk menentukan aksi
    p_aksi VARCHAR, -- 'BUAT_PROYEK', 'UPDATE_PROGRESS', 'UBAH_DETAIL'
    
    -- Parameter Kunci (digunakan di UPDATE/DELETE)
    p_id_proyek BIGINT DEFAULT NULL,
    
    -- Parameter untuk 'BUAT_PROYEK'
    p_nama_proyek VARCHAR(255) DEFAULT NULL,
    p_deskripsi TEXT DEFAULT NULL,
    p_tanggal_mulai DATE DEFAULT NULL,
    p_id_anggaran BIGINT DEFAULT NULL,
    
    -- Parameter untuk 'UPDATE_PROGRESS'
    p_persentase_baru DECIMAL(5, 2) DEFAULT NULL,
    
    -- Parameter untuk 'UBAH_DETAIL'
    p_tanggal_selesai_baru DATE DEFAULT NULL
)
RETURNS TEXT AS $$
BEGIN
    -- ==========================================================
    -- Blok Logika untuk Aksi 'BUAT_PROYEK'
    -- ==========================================================
    IF p_aksi = 'BUAT_PROYEK' THEN
        IF p_nama_proyek IS NULL OR p_tanggal_mulai IS NULL OR p_id_anggaran IS NULL THEN
            RETURN 'Gagal: Nama Proyek, Tanggal Mulai, dan ID Anggaran harus diisi untuk membuat proyek baru.';
        END IF;

        INSERT INTO Proyek_Pembangunan(nama_proyek, deskripsi, tanggal_mulai, status_proyek, anggaran_proyek, persentase_progress, id_anggaran)
        VALUES (p_nama_proyek, p_deskripsi, p_tanggal_mulai, 'Direncanakan', 0.00, 0.00, p_id_anggaran);
        
        RETURN 'Sukses: Proyek baru "' || p_nama_proyek || '" telah berhasil dibuat.';

    -- ==========================================================
    -- Blok Logika untuk Aksi 'UPDATE_PROGRESS'
    -- ==========================================================
    ELSIF p_aksi = 'UPDATE_PROGRESS' THEN
        IF NOT EXISTS (SELECT 1 FROM Proyek_Pembangunan WHERE id_proyek = p_id_proyek) THEN
            RETURN 'Gagal: Proyek dengan ID ' || p_id_proyek || ' tidak ditemukan.';
        END IF;
        IF p_persentase_baru < 0 OR p_persentase_baru > 100 THEN
            RETURN 'Gagal: Persentase harus di antara 0 dan 100.';
        END IF;

        UPDATE Proyek_Pembangunan
        SET
            persentase_progress = p_persentase_baru,
            status_proyek = CASE
                                WHEN p_persentase_baru = 100.00 THEN 'Selesai'
                                WHEN p_persentase_baru > 0.00 THEN 'Diproses'
                                ELSE 'Direncanakan'
                            END,
            tanggal_selesai = CASE
                                WHEN p_persentase_baru = 100.00 THEN CURRENT_DATE
                                ELSE tanggal_selesai
                              END
        WHERE id_proyek = p_id_proyek;
        
        RETURN 'Sukses: Progres proyek ID ' || p_id_proyek || ' telah diperbarui menjadi ' || p_persentase_baru || '%.';

    -- ==========================================================
    -- Blok Logika untuk Aksi 'UBAH_DETAIL'
    -- ==========================================================
    ELSIF p_aksi = 'UBAH_DETAIL' THEN
        IF NOT EXISTS (SELECT 1 FROM Proyek_Pembangunan WHERE id_proyek = p_id_proyek) THEN
            RETURN 'Gagal: Proyek dengan ID ' || p_id_proyek || ' tidak ditemukan.';
        END IF;

        UPDATE Proyek_Pembangunan
        SET
            nama_proyek = COALESCE(p_nama_proyek, nama_proyek),
            deskripsi = COALESCE(p_deskripsi, deskripsi),
            tanggal_selesai = COALESCE(p_tanggal_selesai_baru, tanggal_selesai)
        WHERE id_proyek = p_id_proyek;
        
        RETURN 'Sukses: Detail untuk proyek ID ' || p_id_proyek || ' telah diperbarui.';
        
    -- Jika aksi tidak valid
    ELSE
        RETURN 'Gagal: Aksi "' || p_aksi || '" tidak valid. Gunakan ''BUAT_PROYEK'', ''UPDATE_PROGRESS'', atau ''UBAH_DETAIL''.';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT KelolaProyek(
    p_aksi          := 'BUAT_PROYEK', 
    p_nama_proyek   := 'Penerangan Jalan Kampung Baru', 
    p_deskripsi     := 'Pemasangan lampu di 50 titik di Kampung Baru',
    p_tanggal_mulai := '2025-02-01',
    p_id_anggaran   := 18
);

-- Cek apakah proyek baru sudah masuk
SELECT * FROM Proyek_Pembangunan WHERE nama_proyek = 'Penerangan Jalan Kampung Baru';

-- Memperbarui progres proyek menjadi 50%
SELECT KelolaProyek(
    p_aksi            := 'UPDATE_PROGRESS', 
    p_id_proyek       := 514, 
    p_persentase_baru := 50.00
);

-- Cek status dan persentase proyek ID 3
SELECT id_proyek, status_proyek, persentase_progress FROM Proyek_Pembangunan WHERE id_proyek = 3;
-- Hasil yang diharapkan: status_proyek = 'Diproses', persentase_progress = 50.00

-- Mengubah tanggal selesai proyek ID 3
SELECT KelolaProyek(
    p_aksi                 := 'UBAH_DETAIL', 
    p_id_proyek            := 514, 
    p_tanggal_selesai_baru := '2025-12-31'
);

-- Cek tanggal selesai proyek ID 3
SELECT id_proyek, nama_proyek, tanggal_selesai FROM Proyek_Pembangunan WHERE id_proyek = 514;
-- Hasil yang diharapkan: tanggal_selesai = 2025-12-31
-- Soal 3.2 | Langkah 5 dari 5: pengujian immutability, storno, dan verifikasi hash
-- Memakai jurnal KK-001 dari Soal 1.

-- =====================================================================
-- PENGUJIAN
-- =====================================================================

-- Posting jurnal KK-001 (dari Soal 1) agar memiliki hash
SELECT post_journal(header_id) FROM journal_headers WHERE ref_no = 'KK-001' AND posting_status = 'DRAFT';

-- Test A: mengubah jurnal POSTED harus ditolak
DO $$ BEGIN
    UPDATE journal_headers SET description = 'diubah diam-diam' WHERE ref_no = 'KK-001';
    RAISE NOTICE 'TEST A: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'TEST A: OK ditolak - %', SQLERRM;
END $$;

-- Test B: menghapus jurnal POSTED harus ditolak
DO $$ BEGIN
    DELETE FROM journal_headers WHERE ref_no = 'KK-001';
    RAISE NOTICE 'TEST B: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN raise_exception OR foreign_key_violation THEN
    RAISE NOTICE 'TEST B: OK ditolak - %', SQLERRM;
END $$;

-- Koreksi lewat jurnal pembalik
SELECT reverse_journal(header_id, 'Salah input nominal') FROM journal_headers WHERE ref_no = 'KK-001';

-- Verifikasi integritas rantai hash (semua harus hash_valid = true)
SELECT header_id, ref_no,
       hash_checksum = compute_journal_hash(header_id, prev_hash) AS hash_valid
FROM journal_headers WHERE posting_status = 'POSTED' ORDER BY header_id;

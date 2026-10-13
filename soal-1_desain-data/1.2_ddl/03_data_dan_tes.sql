-- Soal 1.2 | Langkah 3 dari 3: data contoh, jurnal valid, 4 tes negatif, query bukti
-- Prasyarat: 01_ddl.sql dan 02_trigger_keseimbangan.sql
-- Hasil tes tampil di tab Messages/Notices sandbox.

-- ---------- Data contoh ----------
INSERT INTO chart_of_accounts (account_code, account_name, normal_balance, report_class) VALUES
    ('1-1100', 'Kas',            'D', 'NERACA'),
    ('1-1200', 'Bank',           'D', 'NERACA'),
    ('2-1100', 'Utang Usaha',    'K', 'NERACA'),
    ('5-2100', 'Beban Listrik',  'D', 'LABA_RUGI');

-- ---------- Jurnal VALID (header + baris dalam SATU pernyataan/transaksi) ----------
WITH h AS (
    INSERT INTO journal_headers (trx_date, ref_no, description)
    VALUES (CURRENT_DATE, 'KK-001', 'Bayar listrik bulan Oktober')
    RETURNING header_id
)
INSERT INTO journal_lines (header_id, account_id, debit, credit)
SELECT h.header_id, a.account_id, x.d, x.c
FROM h
CROSS JOIN (VALUES ('5-2100', 500000, 0), ('1-1100', 0, 500000)) AS x(code, d, c)
JOIN chart_of_accounts a ON a.account_code = x.code;

-- ---------- PENGUJIAN (semua test negatif harus menampilkan 'OK ditolak') ----------
-- Hasil muncul di tab Messages / Notices pada sandbox.

-- Test 1: debit negatif harus ditolak
DO $$ BEGIN
    INSERT INTO journal_lines (header_id, account_id, debit, credit)
    VALUES ((SELECT header_id FROM journal_headers WHERE ref_no = 'KK-001'), 1, -100, 0);
    RAISE NOTICE 'TEST 1: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'TEST 1: OK ditolak - %', SQLERRM;
END $$;

-- Test 2: debit dan kredit sama-sama nol harus ditolak
DO $$ BEGIN
    INSERT INTO journal_lines (header_id, account_id, debit, credit)
    VALUES ((SELECT header_id FROM journal_headers WHERE ref_no = 'KK-001'), 1, 0, 0);
    RAISE NOTICE 'TEST 2: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'TEST 2: OK ditolak - %', SQLERRM;
END $$;

-- Test 3: menghapus header yang sudah punya baris harus ditolak (ON DELETE RESTRICT)
DO $$ BEGIN
    DELETE FROM journal_headers WHERE ref_no = 'KK-001';
    RAISE NOTICE 'TEST 3: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'TEST 3: OK ditolak - %', SQLERRM;
END $$;

-- Test 4: jurnal tidak seimbang (debit 700.000 vs kredit 500.000) harus ditolak
DO $$ BEGIN
    INSERT INTO journal_headers (trx_date, ref_no, description)
    VALUES (CURRENT_DATE, 'KK-TIMPANG', 'Jurnal sengaja tidak seimbang');
    INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
      ((SELECT header_id FROM journal_headers WHERE ref_no = 'KK-TIMPANG'), 4, 700000, 0),
      ((SELECT header_id FROM journal_headers WHERE ref_no = 'KK-TIMPANG'), 1, 0, 500000);
    SET CONSTRAINTS ALL IMMEDIATE;   -- memicu pengecekan yang biasanya terjadi saat COMMIT
    RAISE NOTICE 'TEST 4: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'TEST 4: OK ditolak - %', SQLERRM;
END $$;

-- ---------- Bukti hasil akhir ----------
-- Hanya jurnal KK-001 yang tersimpan; KK-TIMPANG tidak ada.
SELECT h.ref_no, h.trx_date, a.account_code, a.account_name, l.debit, l.credit
FROM journal_lines l
JOIN journal_headers h ON h.header_id = l.header_id
JOIN chart_of_accounts a ON a.account_id = l.account_id
ORDER BY h.header_id, l.line_id;

-- Cek keseimbangan per jurnal
SELECT h.ref_no, SUM(l.debit) AS total_debit, SUM(l.credit) AS total_kredit,
       SUM(l.debit) = SUM(l.credit) AS seimbang
FROM journal_headers h JOIN journal_lines l ON l.header_id = h.header_id
GROUP BY h.ref_no;

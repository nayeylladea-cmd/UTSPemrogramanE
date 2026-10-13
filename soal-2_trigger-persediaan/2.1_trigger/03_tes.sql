-- Pengujian trigger Soal 2.1

INSERT INTO inventory_items VALUES ('BRG001', 'Kertas A4', 5, 50000);

-- Penjualan 3 unit: stok jadi 2, jurnal HPP Rp150.000 terbentuk
INSERT INTO inventory_transactions (item_id, trx_type, qty) VALUES ('BRG001', 'SALE', 3);

-- Pembelian 4 unit: stok jadi 6
INSERT INTO inventory_transactions (item_id, trx_type, qty) VALUES ('BRG001', 'PURCHASE', 4);

SELECT item_id, stock_qty FROM inventory_items;   -- harus 6

-- Penjualan melebihi stok harus DITOLAK dan stok tidak berubah
DO $$ BEGIN
    INSERT INTO inventory_transactions (item_id, trx_type, qty) VALUES ('BRG001', 'SALE', 10);
    RAISE NOTICE 'TEST: GAGAL (seharusnya ditolak)';
EXCEPTION WHEN raise_exception OR check_violation THEN
    RAISE NOTICE 'TEST: OK ditolak - %', SQLERRM;
END $$;

SELECT item_id, stock_qty FROM inventory_items;   -- tetap 6

-- Jurnal HPP yang terbentuk
SELECT h.ref_no, a.account_code, a.account_name, l.debit, l.credit
FROM journal_headers h
JOIN journal_lines l ON l.header_id = h.header_id
JOIN chart_of_accounts a ON a.account_id = l.account_id
WHERE h.ref_no LIKE 'INV-SALE-%'
ORDER BY h.header_id, l.line_id;

-- Soal 2.1 | Langkah 2 dari 3: fungsi trg_update_stock_and_journal() dan trigger
-- Prasyarat: 01_ddl_tabel.sql

-- OPSIONAL (pengaman lapis kedua di level tabel). Dibiarkan nonaktif agar pesan
-- RAISE EXCEPTION milik trigger yang tampil saat stok kurang. Jika diaktifkan, error
-- dari CHECK ini muncul lebih dulu (SQLSTATE 23514), efeknya sama: transaksi dibatalkan.
-- ALTER TABLE inventory_items ADD CONSTRAINT chk_stock_non_negative CHECK (stock_qty >= 0);

-- Akun yang dipakai jurnal HPP otomatis
INSERT INTO chart_of_accounts (account_code, account_name, normal_balance, report_class) VALUES
    ('1-1300', 'Persediaan Barang Dagang', 'D', 'NERACA'),
    ('5-1000', 'Beban Pokok Pendapatan (HPP)', 'D', 'LABA_RUGI')
ON CONFLICT (account_code) DO NOTHING;

CREATE OR REPLACE FUNCTION trg_update_stock_and_journal() RETURNS TRIGGER AS $$
DECLARE
    v_delta     INT;
    v_new_qty   INT;
    v_unit_cost NUMERIC(15,2);
    v_amount    NUMERIC(18,2);
    v_hdr       BIGINT;
    v_acc_inv   INT;
    v_acc_cogs  INT;
BEGIN
    IF NEW.trx_type IN ('PURCHASE','SALE') AND NEW.qty <= 0 THEN
        RAISE EXCEPTION 'Qty % tidak valid untuk transaksi %', NEW.qty, NEW.trx_type;
    END IF;

    -- PURCHASE menambah, SALE mengurangi, ADJUSTMENT memakai qty bertanda (+/-)
    v_delta := CASE NEW.trx_type
                 WHEN 'PURCHASE'   THEN  NEW.qty
                 WHEN 'SALE'       THEN -NEW.qty
                 WHEN 'ADJUSTMENT' THEN  NEW.qty
               END;

    -- (a) UPDATE ini sekaligus mengunci baris item sampai transaksi selesai
    UPDATE inventory_items
       SET stock_qty = stock_qty + v_delta
     WHERE item_id = NEW.item_id
     RETURNING stock_qty, unit_cost INTO v_new_qty, v_unit_cost;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item % tidak ditemukan', NEW.item_id;
    END IF;

    -- (b) Anti-negative inventory
    IF v_new_qty < 0 THEN
        RAISE EXCEPTION 'Stok item % tidak mencukupi (sisa setelah transaksi: %)',
                        NEW.item_id, v_new_qty;
    END IF;

    -- Jurnal HPP otomatis: Dr HPP, Cr Persediaan
    IF NEW.trx_type = 'SALE' THEN
        v_amount := NEW.qty * v_unit_cost;
        IF v_amount > 0 THEN
            SELECT account_id INTO v_acc_inv  FROM chart_of_accounts WHERE account_code = '1-1300';
            SELECT account_id INTO v_acc_cogs FROM chart_of_accounts WHERE account_code = '5-1000';
            IF v_acc_inv IS NULL OR v_acc_cogs IS NULL THEN
                RAISE EXCEPTION 'Akun Persediaan/HPP belum ada di chart_of_accounts';
            END IF;

            INSERT INTO journal_headers (trx_date, ref_no, description)
            VALUES (NEW.trx_date::date, 'INV-SALE-' || NEW.trx_id,
                    'HPP penjualan item ' || NEW.item_id)
            RETURNING header_id INTO v_hdr;

            INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
                (v_hdr, v_acc_cogs, v_amount, 0),
                (v_hdr, v_acc_inv,  0, v_amount);

            UPDATE journal_headers SET posting_status = 'POSTED' WHERE header_id = v_hdr;
            -- Setelah soal3/02_audit_trail.sql dijalankan, baris di atas dapat diganti:
            -- PERFORM post_journal(v_hdr);
        END IF;
    END IF;

    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_after_insert
    AFTER INSERT ON inventory_transactions
    FOR EACH ROW EXECUTE FUNCTION trg_update_stock_and_journal();

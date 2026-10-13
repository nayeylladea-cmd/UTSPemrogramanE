-- Soal 2.2: Penanganan race condition (dua kasir, stok tersisa 1)
-- Contoh ini ditulis sebagai referensi; untuk mensimulasikan, buka dua sesi/tab SQL.

-- Solusi 1: pessimistic locking dengan SELECT ... FOR UPDATE
BEGIN;
SELECT stock_qty FROM inventory_items WHERE item_id = 'BRG001' FOR UPDATE;  -- kunci baris
-- aplikasi memeriksa stock_qty >= qty yang dijual, lalu:
INSERT INTO inventory_transactions (item_id, trx_type, qty) VALUES ('BRG001', 'SALE', 1);
COMMIT;

-- Solusi 2: UPDATE atomik bersyarat (cek dan kurangi dalam satu pernyataan)
UPDATE inventory_items
   SET stock_qty = stock_qty - 1
 WHERE item_id = 'BRG001' AND stock_qty >= 1;
-- jika jumlah baris terpengaruh = 0 maka stok habis, batalkan penjualan

-- Solusi 3: isolasi SERIALIZABLE dengan retry
BEGIN ISOLATION LEVEL SERIALIZABLE;
INSERT INTO inventory_transactions (item_id, trx_type, qty) VALUES ('BRG001', 'SALE', 1);
COMMIT;
-- Bila terjadi SQLSTATE 40001 (serialization_failure), aplikasi mengulang seluruh transaksi.

-- Catatan: UPDATE di dalam trigger Soal 2.1 sudah mengunci baris item. Pada READ COMMITTED,
-- transaksi kedua menunggu, membaca stok terbaru (0), lalu trigger memunculkan RAISE EXCEPTION.
-- Untuk transaksi multi-item, kunci item dengan urutan yang sama (ORDER BY item_id) agar tidak deadlock.

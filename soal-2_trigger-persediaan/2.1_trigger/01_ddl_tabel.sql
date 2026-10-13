-- Soal 2.1 | Langkah 1 dari 3: tabel dari soal
-- Prasyarat: seluruh skrip Soal 1 (tabel jurnal harus sudah ada)

DROP TABLE IF EXISTS inventory_transactions CASCADE;
DROP TABLE IF EXISTS inventory_items CASCADE;

-- Struktur tabel dari soal
CREATE TABLE inventory_items (
    item_id    VARCHAR(10) PRIMARY KEY,
    item_name  VARCHAR(100),
    stock_qty  INT NOT NULL DEFAULT 0,
    unit_cost  NUMERIC(15, 2) NOT NULL
);

CREATE TABLE inventory_transactions (
    trx_id    SERIAL PRIMARY KEY,
    item_id   VARCHAR(10) REFERENCES inventory_items(item_id),
    trx_type  VARCHAR(10) CHECK (trx_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT')),
    qty       INT NOT NULL,
    trx_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


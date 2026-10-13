-- Soal 1.2 | Langkah 1 dari 3: DDL tabel, PK, FK (ON DELETE RESTRICT), CHECK
-- Jalankan paling awal.

-- ---------- (Opsional) reset agar skrip bisa dijalankan ulang ----------
DROP TABLE IF EXISTS journal_lines CASCADE;
DROP TABLE IF EXISTS journal_headers CASCADE;
DROP TABLE IF EXISTS chart_of_accounts CASCADE;
DROP FUNCTION IF EXISTS fn_check_journal_balanced() CASCADE;

-- ---------- 1.1 & 1.2 DDL ----------
CREATE TABLE chart_of_accounts (
    account_id      SERIAL       PRIMARY KEY,
    account_code    VARCHAR(20)  NOT NULL UNIQUE,
    account_name    VARCHAR(150) NOT NULL,
    normal_balance  CHAR(1)      NOT NULL CHECK (normal_balance IN ('D','K')),
    report_class    VARCHAR(20)  NOT NULL CHECK (report_class IN ('NERACA','LABA_RUGI'))
);

CREATE TABLE journal_headers (
    header_id       BIGSERIAL    PRIMARY KEY,
    trx_date        DATE         NOT NULL,
    ref_no          VARCHAR(50)  NOT NULL UNIQUE,
    description     TEXT         NOT NULL,
    posting_status  VARCHAR(10)  NOT NULL DEFAULT 'DRAFT'
                    CHECK (posting_status IN ('DRAFT','POSTED'))
);

CREATE TABLE journal_lines (
    line_id     BIGSERIAL     PRIMARY KEY,
    header_id   BIGINT        NOT NULL
                REFERENCES journal_headers(header_id) ON DELETE RESTRICT,
    account_id  INT           NOT NULL
                REFERENCES chart_of_accounts(account_id) ON DELETE RESTRICT,
    debit       NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK (debit  >= 0),
    credit      NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
    CONSTRAINT chk_not_both_zero CHECK (debit > 0 OR credit > 0)
);

CREATE INDEX idx_lines_header  ON journal_lines(header_id);
CREATE INDEX idx_lines_account ON journal_lines(account_id);


-- Soal 3.2 | Langkah 1 dari 5: kolom audit (created_by, created_at, hash_checksum, reversal_of)
-- Prasyarat: seluruh skrip Soal 1

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Langkah 1: kolom audit
ALTER TABLE journal_headers
    ADD COLUMN created_by    TEXT        NOT NULL DEFAULT current_user,  -- di Supabase: DEFAULT auth.uid()::text
    ADD COLUMN created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN hash_checksum CHAR(64),
    ADD COLUMN prev_hash     CHAR(64),
    ADD COLUMN reversal_of   BIGINT REFERENCES journal_headers(header_id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_one_reversal ON journal_headers(reversal_of) WHERE reversal_of IS NOT NULL;


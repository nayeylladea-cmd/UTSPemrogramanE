-- Soal 3.2 | Langkah 3 dari 5: hash chain SHA-256 dan fungsi post_journal()

-- Langkah 3: hash chain dan posting
CREATE OR REPLACE FUNCTION compute_journal_hash(p_header_id BIGINT, p_prev TEXT) RETURNS TEXT AS $$
DECLARE h journal_headers%ROWTYPE; v_lines TEXT;
BEGIN
    SELECT * INTO h FROM journal_headers WHERE header_id = p_header_id;
    SELECT string_agg(account_id || ':' || debit || ':' || credit, ';' ORDER BY line_id)
      INTO v_lines FROM journal_lines WHERE header_id = p_header_id;
    RETURN encode(digest(concat_ws('|',
        h.header_id, h.trx_date, h.ref_no, h.description, h.created_by,
        to_char(h.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD HH24:MI:SS.US'),
        COALESCE(p_prev,''), v_lines), 'sha256'), 'hex');
END; $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION post_journal(p_header_id BIGINT) RETURNS TEXT AS $$
DECLARE v_prev TEXT; v_hash TEXT; v_debit NUMERIC; v_credit NUMERIC;
BEGIN
    PERFORM pg_advisory_xact_lock(1001);  -- serialisasi pembentukan rantai hash
    PERFORM 1 FROM journal_headers WHERE header_id = p_header_id AND posting_status = 'DRAFT' FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Jurnal % tidak ada atau bukan DRAFT', p_header_id; END IF;

    SELECT COALESCE(SUM(debit),0), COALESCE(SUM(credit),0) INTO v_debit, v_credit
      FROM journal_lines WHERE header_id = p_header_id;
    IF v_debit = 0 OR v_debit <> v_credit THEN
        RAISE EXCEPTION 'Jurnal % kosong atau tidak seimbang', p_header_id;
    END IF;

    SELECT hash_checksum INTO v_prev FROM journal_headers
     WHERE posting_status = 'POSTED' ORDER BY header_id DESC LIMIT 1;
    v_hash := compute_journal_hash(p_header_id, v_prev);

    UPDATE journal_headers
       SET posting_status = 'POSTED', hash_checksum = v_hash, prev_hash = v_prev
     WHERE header_id = p_header_id;
    RETURN v_hash;
END; $$ LANGUAGE plpgsql;


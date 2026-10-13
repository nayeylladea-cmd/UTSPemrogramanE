-- Soal 3.2 | Langkah 4 dari 5: jurnal pembalik (storno) reverse_journal()

-- Langkah 4: jurnal pembalik (storno)
CREATE OR REPLACE FUNCTION reverse_journal(p_header_id BIGINT, p_reason TEXT) RETURNS BIGINT AS $$
DECLARE o journal_headers%ROWTYPE; v_new BIGINT;
BEGIN
    SELECT * INTO o FROM journal_headers WHERE header_id = p_header_id AND posting_status = 'POSTED';
    IF NOT FOUND THEN RAISE EXCEPTION 'Hanya jurnal POSTED yang dapat dibalik'; END IF;

    INSERT INTO journal_headers (trx_date, ref_no, description, reversal_of)
    VALUES (CURRENT_DATE, o.ref_no || '-REV', 'Storno ' || o.ref_no || ': ' || p_reason, o.header_id)
    RETURNING header_id INTO v_new;  -- uq_one_reversal mencegah pembalikan ganda

    INSERT INTO journal_lines (header_id, account_id, debit, credit)
    SELECT v_new, account_id, credit, debit FROM journal_lines WHERE header_id = o.header_id;

    PERFORM post_journal(v_new);
    RETURN v_new;
END; $$ LANGUAGE plpgsql;


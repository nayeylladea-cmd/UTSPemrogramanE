-- Soal 1.2 | Langkah 2 dari 3: constraint trigger Debit = Kredit (ditunda sampai COMMIT)
-- Prasyarat: 01_ddl.sql

-- ---------- Penegakan Debit = Kredit di level database ----------
CREATE OR REPLACE FUNCTION fn_check_journal_balanced() RETURNS TRIGGER AS $$
DECLARE
    v_id BIGINT; v_debit NUMERIC; v_credit NUMERIC;
BEGIN
    IF TG_OP = 'DELETE' THEN v_id := OLD.header_id; ELSE v_id := NEW.header_id; END IF;

    SELECT COALESCE(SUM(debit),0), COALESCE(SUM(credit),0)
      INTO v_debit, v_credit
      FROM journal_lines WHERE header_id = v_id;

    IF v_debit <> v_credit THEN
        RAISE EXCEPTION 'Jurnal % tidak seimbang: debit=% kredit=%', v_id, v_debit, v_credit
              USING ERRCODE = '23514';
    END IF;
    RETURN NULL;
END; $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER ctrg_journal_balanced
    AFTER INSERT OR UPDATE OR DELETE ON journal_lines
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_check_journal_balanced();


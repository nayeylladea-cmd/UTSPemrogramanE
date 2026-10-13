-- Soal 3.2 | Langkah 2 dari 5: kunci immutability jurnal POSTED

-- Langkah 2: kunci immutability
CREATE OR REPLACE FUNCTION fn_block_posted_header() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.posting_status = 'POSTED' THEN
        RAISE EXCEPTION 'Jurnal % berstatus POSTED dan tidak dapat diubah/dihapus. Gunakan jurnal pembalik.', OLD.header_id;
    END IF;
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_posted_header
    BEFORE UPDATE OR DELETE ON journal_headers
    FOR EACH ROW EXECUTE FUNCTION fn_block_posted_header();

CREATE OR REPLACE FUNCTION fn_block_posted_lines() RETURNS TRIGGER AS $$
DECLARE v_id BIGINT; v_status TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN v_id := OLD.header_id; ELSE v_id := NEW.header_id; END IF;
    SELECT posting_status INTO v_status FROM journal_headers WHERE header_id = v_id;
    IF v_status = 'POSTED' THEN
        RAISE EXCEPTION 'Baris jurnal % milik jurnal POSTED dan tidak dapat diubah.', v_id;
    END IF;
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_posted_lines
    BEFORE INSERT OR UPDATE OR DELETE ON journal_lines
    FOR EACH ROW EXECUTE FUNCTION fn_block_posted_lines();


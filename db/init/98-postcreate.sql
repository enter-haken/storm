
CREATE FUNCTION metadata_trigger() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END
$$ LANGUAGE plpgsql;


-- add created_at and updated_at columns to every table
-- and add update trigger to every table

DO $$
DECLARE
    row record;
    current_table TEXT;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE "' || row.tablename ||
            '" ADD COLUMN created_at timestamp NOT NULL DEFAULT NOW();';

        EXECUTE 'ALTER TABLE "' || row.tablename ||
            '" ADD COLUMN updated_at timestamp NOT NULL DEFAULT NOW();';
        
        EXECUTE 'CREATE TRIGGER ' || row.tablename || '_metadata_trigger BEFORE UPDATE ON "' || row.tablename ||
            '" FOR EACH ROW EXECUTE PROCEDURE metadata_trigger();';
    END LOOP;
END
$$ LANGUAGE plpgsql;


-- add set_xxx_dirty and xxx_is_dirty functions to every table, having a `json_view` column

DO $$
DECLARE
  current_table TEXT;
 _sql TEXT; 
BEGIN
  FOR current_table IN SELECT table_name FROM information_schema.columns 
    WHERE column_name = 'json_view'
  LOOP

  EXECUTE format('CREATE FUNCTION set_%1$s_dirty(%1$s_id UUID, caused_by VARCHAR(128) DEFAULT ''unknown'') RETURNS VOID AS %2$s%2$s
    BEGIN
      UPDATE "%1$s" SET json_view = jsonb_set(json_view, ''{is_dirty}'', ''true'') WHERE id = %1$s_id;
      RAISE NOTICE ''%1$s %% has been set to dirty (%%)'', %1$s_id, caused_by;
    END
    %2$s%2$s LANGUAGE plpgsql;', current_table, '$');
        
    EXECUTE format('CREATE FUNCTION %1$s_is_dirty(%1$s_id UUID) RETURNS BOOLEAN AS %2$s%2$s
    DECLARE
      result BOOLEAN;
    BEGIN
      SELECT json_view -> ''is_dirty'' FROM "%1$s" INTO result;
      RETURN result;
    END
    %2$s%2$s LANGUAGE plpgsql;', current_table, '$');
        
  END LOOP;
END
$$ LANGUAGE plpgsql;

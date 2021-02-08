CREATE FUNCTION on_collection_update() RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_collection_dirty(NEW.id);
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_collection_delete() RETURNS TRIGGER AS $$
BEGIN
  -- cascade delete on user will delete all collection data

  DELETE FROM "user" WHERE id IN (
    SELECT id_user FROM "collection_user" 
    WHERE collection_id = OLD.id);

END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_collection_set_dirty() RETURNS TRIGGER AS $$
BEGIN
  -- TODO: the update trigger is fired every time json_view is updated
  -- - set dirty ---- is dirty flag needed?
  SELECT get_collection_json_view(NEW.id) INTO NEW.json_view;

  PERFORM pg_notify('storm',NEW.id::TEXT);
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER sesson_update_trigger AFTER UPDATE OF title, description, is_visible ON collection
  FOR EACH ROW EXECUTE PROCEDURE on_collection_update();

CREATE TRIGGER sesson_set_dirty_trigger BEFORE UPDATE OF json_view ON collection
   FOR EACH ROW EXECUTE PROCEDURE on_collection_set_dirty();

CREATE TRIGGER sesson_delete_trigger AFTER DELETE ON collection
  FOR EACH ROW EXECUTE PROCEDURE on_collection_delete();

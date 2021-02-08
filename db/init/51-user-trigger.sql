CREATE FUNCTION on_user_change() RETURNS TRIGGER AS $$
DECLARE 
  browser_session_id UUID;
BEGIN
  PERFORM set_collection_dirty(NEW.id_collection, 'change/add user');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_user_delete() RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_collection_dirty(OLD.id_collection, 'delete user');

  RETURN OLD;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER user_update_trigger AFTER UPDATE OF
  name, 
  show_identity, 
  is_owner ON "user"
  FOR EACH ROW EXECUTE PROCEDURE on_user_change();

CREATE TRIGGER user_add_trigger AFTER INSERT ON "user"
  FOR EACH ROW EXECUTE PROCEDURE on_user_change();

CREATE TRIGGER user_delete_trigger AFTER DELETE ON "user"
  FOR EACH ROW EXECUTE PROCEDURE on_user_delete();

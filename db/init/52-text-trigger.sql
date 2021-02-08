CREATE FUNCTION on_text_update() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN
  SELECT si.id_collection FROM idea_text it
    JOIN collection_idea si on si.id_idea = it.id_idea
    WHERE it.id_text = NEW.id
    INTO collection_id;

  PERFORM set_collection_dirty(collection_id, 'update text');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_text_insert() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN
  SELECT id_collection FROM collection_idea
    WHERE id_idea = NEW.id_idea
    INTO collection_id;

  PERFORM set_collection_dirty(collection_id, 'insert text');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_text_delete() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN
  SELECT id_collection FROM collection_idea
    WHERE id_idea = OLD.id_idea
    INTO collection_id;

  PERFORM set_collection_dirty(collection_id, 'delete text');

  RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER text_update_trigger AFTER UPDATE OF
  content, is_visible ON text 
  FOR EACH ROW EXECUTE PROCEDURE on_text_update();

CREATE TRIGGER text_inseret_trigger AFTER INSERT ON idea_text 
  FOR EACH ROW EXECUTE PROCEDURE on_text_insert();

CREATE TRIGGER text_delete_trigger AFTER DELETE ON idea_text
  FOR EACH ROW EXECUTE PROCEDURE on_text_delete();

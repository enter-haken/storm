CREATE FUNCTION on_idea_update() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN
  SELECT id_collection FROM collection_idea 
    WHERE id_idea = NEW.id 
    INTO collection_id;

  PERFORM set_collection_dirty(collection_id, 'update_idea');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_idea_insert() RETURNS TRIGGER AS $$
BEGIN
  RAISE NOTICE 'new idea % has been added', NEW.id_idea;

  PERFORM set_collection_dirty(NEW.id_collection, 'insert_idea');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_idea_delete() RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_collection_dirty(OLD.id_collection, 'delete_idea');
  RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_like_insert() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN

  SELECT c.id FROM collection c
    JOIN collection_idea ci ON c.id = ci.id_collection
    WHERE ci.id_idea = NEW.id_idea INTO collection_id;

  RAISE NOTICE 'new like has been added to idea % in collection %', NEW.id_idea, collection_id;

  PERFORM set_collection_dirty(collection_id, 'insert like');

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_like_delete() RETURNS TRIGGER AS $$
DECLARE
  collection_id UUID;
BEGIN
  RAISE NOTICE 'new idea % has been added', OLD.id_idea;

  SELECT c.id FROM collection c
    JOIN collection_idea ci ON c.id = ci.id_collection
    WHERE ci.id_idea = OLD.id_idea INTO collection_id;

  PERFORM set_collection_dirty(collection_id, 'delete like');

  RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER idea_update_trigger AFTER UPDATE OF 
  content, description, is_visible ON idea 
  FOR EACH ROW EXECUTE PROCEDURE on_idea_update();

CREATE TRIGGER idea_insert_trigger AFTER INSERT ON collection_idea
  FOR EACH ROW EXECUTE PROCEDURE on_idea_insert();

CREATE TRIGGER idea_delete_trigger AFTER DELETE ON collection_idea
  FOR EACH ROW EXECUTE PROCEDURE on_idea_delete();

CREATE TRIGGER idea_insert_like_trigger AFTER INSERT ON idea_like 
  FOR EACH ROW EXECUTE PROCEDURE on_like_insert();

CREATE TRIGGER idea_delete_like_trigger AFTER DELETE ON idea_like 
  FOR EACH ROW EXECUTE PROCEDURE on_like_delete();

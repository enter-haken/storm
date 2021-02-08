CREATE FUNCTION insert_collection() RETURNS JSONB AS $$
DECLARE
  collection_id UUID;
  owner_id UUID;
BEGIN
  INSERT INTO "collection" DEFAULT VALUES RETURNING id INTO collection_id;
  SELECT insert_owner(collection_id) INTO owner_id;

  RAISE NOTICE 'created new collection % with owner %', collection_id, owner_id;

  RETURN '{}'::JSONB
     || jsonb_build_object('collection_id', collection_id)
     || jsonb_build_object('owner_id', owner_id);

END
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_collection_title(collection_id UUID, newTitle VARCHAR(1024)) RETURNS VOID AS $$
BEGIN
  UPDATE "collection" SET title = newTitle WHERE id = collection_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_collection_description(collection_id UUID, newDescription VARCHAR(4196)) RETURNS VOID AS $$
BEGIN
  UPDATE "collection" SET description = newDescription WHERE id = collection_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_collection(collection_id UUID) RETURNS VOID AS $$
BEGIN
  DELETE FROM "collection" WHERE id = collection_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION toggle_collection_visibility(collection_id UUID) RETURNS UUID AS $$
BEGIN
  UPDATE "collection" SET is_visible = NOT is_visible WHERE id = collection_id;

  RAISE NOTICE 'update collection visibility';
  RETURN collection_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_collection_json_view(collection_id UUID) RETURNS JSONB AS $$
DECLARE
  collection_raw JSONB;
  user_array JSONB;
  user_id UUID;

  idea_array JSONB;
  idea_id UUID;
BEGIN
  SELECT row_to_json(currentcollection) FROM
      (SELECT id, 
      title,
      description,
      is_visible
      FROM collection
      WHERE id = collection_id) currentcollection 
    INTO collection_raw;

  user_array := '[]'::JSONB;

  FOR user_id in SELECT id FROM "user" WHERE id_collection = collection_id
  LOOP
    user_array := user_array || get_user(user_id); 
  END LOOP;

  idea_array := '[]'::JSONB;

  FOR idea_id in SELECT id_idea FROM collection_idea WHERE id_collection = collection_id
  LOOP
    idea_array := idea_array || get_idea(idea_id); 
  END LOOP;

  collection_raw := collection_raw 
    || jsonb_build_object('users', user_array)
    || jsonb_build_object('ideas', idea_array)
    || get_default_entity();

  RETURN collection_raw;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_collection(collection_id UUID) RETURNS JSONB AS $$
DECLARE 
  response JSONB;
BEGIN
  SELECT json_view FROM "collection" WHERE id = collection_id INTO response;
  RETURN response;
END
$$ LANGUAGE plpgsql;

-- TODO: remove, when search is in place

CREATE FUNCTION get_collections(page INT DEFAULT 1, page_size INT DEFAULT 20) RETURNS JSONB AS
$$
DECLARE 
  collections JSONB;
  total_collections INTEGER;
BEGIN
  SELECT json_agg(row_to_json(allcollections)) FROM
    (SELECT id, 
      title, 
      description,
      is_visible
      FROM collection
      ORDER BY updated_at
      LIMIT page_size OFFSET page_size*(page-1)
    ) allcollections 
    INTO collections;

    SELECT COUNT(1) FROM collection INTO total_collections;

    RETURN '{}'::JSONB
      || jsonb_build_object('collections', collections)
      || jsonb_build_object('page', page)
      || jsonb_build_object('page_size', page_size)
      || jsonb_build_object('total', total_collections);

END
$$ LANGUAGE plpgsql;

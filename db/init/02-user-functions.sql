CREATE FUNCTION insert_user(collection_id UUID) RETURNS UUID AS $$
DECLARE
  user_id UUID;
BEGIN
  INSERT INTO "user" (id_collection) VALUES (collection_id) RETURNING id INTO user_id;
  RETURN user_id;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION delete_user(user_id UUID) RETURNS VOID AS $$
BEGIN
  DELETE FROM "user" WHERE id = user_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_owner(collection_id UUID) RETURNS UUID AS $$
DECLARE
  user_id UUID;
BEGIN
  INSERT INTO "user" (id_collection, is_owner) VALUES (collection_id, true) RETURNING id INTO user_id;
  RETURN user_id;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION update_user_name(user_id UUID, new_name varchar(256)) RETURNS void AS $$
BEGIN
  UPDATE "user" SET name = new_name WHERE id = user_id;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION update_show_identity(user_id UUID, show_identity BOOLEAN) RETURNS void AS $$
BEGIN
  UPDATE "user" SET show_identity = show_identity WHERE id = user_id;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION get_user(user_id UUID) RETURNS JSONB AS $$
DECLARE
  response JSONB;
BEGIN
  SELECT row_to_json(currentUser) FROM
    (SELECT id,
      name,
      show_identity,
      is_owner FROM "user"
      WHERE id = user_id) currentUser
    INTO response;

  RETURN response;
END
$$ LANGUAGE PLPGSQL;

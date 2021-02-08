CREATE FUNCTION insert_idea(collection_id UUID, user_id UUID) RETURNS UUID AS $$
DECLARE
  idea_id UUID;
BEGIN
  INSERT INTO idea (id_creator) 
    VALUES (user_id) 
    RETURNING id INTO idea_id;

  RAISE NOTICE 'inserted idea % for collection % and creator %', idea_id, collection_id, user_id;

  INSERT INTO "collection_idea" (id_collection, id_idea) VALUES (collection_id, idea_id);

  RETURN idea_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION toggle_idea_visibility(idea_id UUID) RETURNS UUID AS $$
BEGIN
  UPDATE idea SET is_visible = NOT is_visible WHERE id = idea_id;

  RETURN idea_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_idea_content(idea_id UUID, new_content VARCHAR(2048)) RETURNS UUID AS $$
BEGIN
  UPDATE idea SET content = new_content WHERE id = idea_id;

  RETURN idea_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_idea_description(idea_id UUID, new_description VARCHAR(4196)) RETURNS UUID AS $$
BEGIN
  UPDATE idea SET description = new_description WHERE id = idea_id;

  RETURN idea_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_like(idea_id UUID, user_id UUID) RETURNS VOID AS $$
BEGIN
  INSERT INTO idea_like (id_user, id_idea) VALUES (user_id, idea_id);
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_like(idea_id UUID, user_id UUID) RETURNS VOID AS $$
BEGIN
  DELETE FROM idea_like WHERE id_idea = idea_id AND id_user = user_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_idea(idea_id UUID) RETURNS VOID AS $$
BEGIN
  DELETE FROM idea WHERE id = idea_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_idea(idea_id UUID) RETURNS JSONB AS $$
DECLARE
  idea_raw JSONB;

  creator_id UUID;

  pro_array JSONB;
  con_array JSONB;
  comment_array JSONB;
  likes_array JSONB;

  pro_id UUID;
  con_id UUID;
  comment_id UUID;
  like_id UUID;
BEGIN
  SELECT row_to_json(currentIdea) FROM
    (SELECT id, 
      content, 
      description,
      is_visible
      FROM idea
      WHERE id = idea_id) currentIdea
    INTO idea_raw;

  pro_array := '[]'::JSONB;
  con_array := '[]'::JSONB;
  comment_array := '[]'::JSONB;
  likes_array := '[]'::JSONB;

  FOR pro_id in SELECT id_text FROM idea_text   
    WHERE id_idea = idea_id AND content_type = 'pro'
  LOOP
    pro_array := pro_array || get_text(pro_id); 
  END LOOP;

  FOR con_id in SELECT id_text FROM idea_text   
    WHERE id_idea = idea_id AND content_type = 'con'
  LOOP
    con_array := con_array || get_text(con_id); 
  END LOOP;

  FOR comment_id in SELECT id_text FROM idea_text   
    WHERE id_idea = idea_id AND content_type = 'comment'
  LOOP
    comment_array := comment_array || get_text(comment_id); 
  END LOOP;

  FOR like_id in SELECT id_user FROM idea_like
    WHERE id_idea = idea_id
  LOOP
    likes_array := likes_array || get_user(like_id); 
  END LOOP;

  SELECT id_creator FROM idea WHERE id = idea_id INTO creator_id;

  idea_raw := idea_raw
    || jsonb_build_object('pros', pro_array)
    || jsonb_build_object('cons', con_array)
    || jsonb_build_object('comments', comment_array)
    || jsonb_build_object('likes', likes_array)
    || jsonb_build_object('creator', get_user(creator_id))
    || get_default_entity();

  RETURN idea_raw;
END
$$ LANGUAGE plpgsql;

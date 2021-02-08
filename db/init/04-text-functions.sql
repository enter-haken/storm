CREATE FUNCTION insert_text(idea_id UUID, user_id UUID, content_type content_type) RETURNS UUID AS $$
DECLARE
  text_id UUID;
BEGIN
  INSERT INTO text (id_creator) VALUES (user_id) RETURNING id INTO text_id;
  INSERT INTO idea_text (id_idea, id_text, content_type) VALUES (idea_id, text_id, content_type);

  RETURN text_id;
END
$$ LANGUAGE plpgsql;

-- INSERT pro, con, comment

CREATE FUNCTION insert_pro(idea_id UUID, user_id UUID) RETURNS UUID AS $$
DECLARE
  text_id UUID;
BEGIN
  SELECT insert_text(idea_id, user_id, 'pro') INTO text_id;

  RETURN text_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_con(idea_id UUID, user_id UUID) RETURNS UUID AS $$
DECLARE
  text_id UUID;
BEGIN
  SELECT insert_text(idea_id, user_id, 'con') INTO text_id;

  RETURN text_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_comment(idea_id UUID, user_id UUID) RETURNS UUID AS $$
DECLARE
  text_id UUID;
BEGIN
  SELECT insert_text(idea_id, user_id, 'comment') INTO text_id;

  RETURN text_id;
END
$$ LANGUAGE plpgsql;

-- generic update and delete statements

CREATE FUNCTION update_text(text_id UUID, newContent TEXT) RETURNS UUID AS $$
BEGIN
  UPDATE text SET content = newContent WHERE id = text_id;

  RETURN text_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_text(text_id UUID) RETURNS VOID AS $$
BEGIN
  DELETE FROM text WHERE id = text_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION toggle_text_visibility(text_id UUID) RETURNS VOID AS $$
BEGIN
  UPDATE text SET is_visible = NOT is_visible WHERE id = text_id;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_text(text_id UUID) RETURNS JSONB AS $$
DECLARE
  text_raw JSONB;
  creator_id UUID;
BEGIN
  SELECT row_to_json(currentText) FROM
    (SELECT id, 
      content,
      is_visible
      FROM text 
      WHERE id = text_id) currentText
    INTO text_raw;

  SELECT id_creator FROM text 
    WHERE id = text_id 
    INTO creator_id;

  text_raw := text_raw
    || jsonb_build_object('creator', get_user(creator_id));

  RETURN text_raw;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_browser_session(browser_session_id UUID, collection_id UUID, user_id UUID) RETURNS VOID AS $$
BEGIN
  INSERT INTO browser_session (id_browser_session, id_collection, id_user) 
    VALUES (browser_session_id, collection_id, user_id);

  PERFORM pg_notify('browser_session',browser_session_id::TEXT);

END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION get_browser_session(browser_session_id UUID) RETURNS JSONB AS
$$
DECLARE 
  sessions JSONB;
BEGIN
  SELECT json_agg(row_to_json(allSessions)) FROM
    (SELECT id_browser_session,
      id_collection, 
      id_user
      FROM browser_session WHERE id_browser_session = browser_session_id) allSessions 
    INTO sessions;

    RETURN sessions;
END
$$ LANGUAGE plpgsql;

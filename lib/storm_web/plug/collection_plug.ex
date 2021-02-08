defmodule StormWeb.SessionPlug do
  import Plug.Conn

  def init_session(conn, _params) do
    case get_session(conn, :storm_uuid) do
      nil ->
        conn
        |> put_session(:storm_uuid, UUID.uuid4())

      _ ->
        conn
    end
  end
end

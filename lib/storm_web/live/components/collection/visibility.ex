defmodule StormWeb.Live.Components.Collection.Visibility do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button class="button" phx-click="toggle_visibility" phx-target="<%= @myself %>">
      <span class="icon is-small">
        <i class="<%= is_visible_icon_class(@storm_collection) %>"></i>
      </span>
      <span>
        <%= is_visible_button_text(@storm_collection) %>
      </span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(_,_), do: false

  def update(
        %{
          active_user: active_user,
          storm_collection: storm_collection,
          active_collections: active_collections,
          storm_uuid: storm_uuid
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       active_user: active_user,
       storm_collection: storm_collection,
       active_collections: active_collections,
       storm_uuid: storm_uuid
     )}
  end

  def handle_event(
        "toggle_visibility",
        _value,
        socket
      ) do
    %Storm.BrowserSession{collection_id: collection_id} =
      socket |> Storm.BrowserSession.get_browser_session()

    Storm.Db.Crud.toggle_collection_visibility(collection_id)

    {:noreply, socket}
  end

  defp is_visible_icon_class(%Storm.Collection{is_visible: is_visible}) do
    if is_visible do
      "fas fa-eye"
    else
      "fas fa-eye-slash"
    end
  end

  defp is_visible_button_text(%Storm.Collection{is_visible: is_visible}) do
    if is_visible do
      "Public"
    else
      "Private"
    end
  end
end

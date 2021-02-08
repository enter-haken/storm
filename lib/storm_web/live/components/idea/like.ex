defmodule StormWeb.Live.Components.Idea.Like do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button class="button" phx-click="toggle_like" phx-target="<%= @myself %>">
      <span class="icon is-small">
        <i class="<%= is_liked?(@idea, @active_user) %>"></i>
      </span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(
        %{
          idea: idea,
          active_user: active_user,
          storm_collection: storm_collection,
          active_collections: active_collections,
          storm_uuid: storm_uuid
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       idea: idea,
       active_user: active_user,
       storm_collection: storm_collection,
       active_collections: active_collections,
       storm_uuid: storm_uuid
     )}
  end

  def handle_event(
        "toggle_like",
        _value,
        %{
          assigns: %{
            idea: %Storm.Idea{
              id: idea_id,
              likes: likes
            }
          }
        } = socket
      ) do
    %Storm.BrowserSession{user_id: user_id} = socket |> Storm.BrowserSession.get_browser_session()

    if likes
       |> Enum.any?(fn %Storm.User{id: possible_user_id} -> possible_user_id == user_id end) do
      Storm.Db.Crud.delete_like(idea_id, user_id)
    else
      Storm.Db.Crud.add_like(idea_id, user_id)
    end

    {:noreply, socket}
  end

  defp is_liked?(%Storm.Idea{likes: likes}, %Storm.User{id: user_id}) do
    if likes
       |> Enum.any?(fn %Storm.User{id: user_likes_idea} -> user_likes_idea == user_id end) do
      "fas fa-heart"
    else
      "far fa-heart"
    end
  end

  defp is_liked?(_, nil), do: "far fa-heart"
end

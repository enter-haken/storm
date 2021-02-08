defmodule StormWeb.Live.Components.Idea.Visibility do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button class="button" phx-click="toggle_visibility" phx-target="<%= @myself %>">
      <span class="icon is-small">
        <i class="<%= is_visible?(@idea) %>"></i>
      </span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(
        %{
          idea: idea
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       idea: idea
     )}
  end

  def handle_event(
        "toggle_visibility",
        _value,
        %{
          assigns: %{
            idea: %Storm.Idea{
              id: idea_id
            }
          }
        } = socket
      ) do

    Storm.Db.Crud.toggle_idea_visibility(idea_id)

    {:noreply, socket}
  end

  defp is_visible?(%Storm.Idea{is_visible: is_visible}) do
    if is_visible do
      "fas fa-eye"
    else
      "fas fa-eye-slash"
    end
  end
end

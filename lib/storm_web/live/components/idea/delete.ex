defmodule StormWeb.Live.Components.Idea.Delete do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button phx-click="delete_idea" phx-target="<%= @myself %>" class="button">
      <span class="icon">
        <i class="fas fa-trash"></i>
      </span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event(
        "delete_idea",
        _value,
        %{
          assigns: %{
            idea: %Storm.Idea{
              id: id
            }
          }
        } = socket
      ) do
    Storm.Db.Crud.delete_idea(id)

    {:noreply, socket}
  end
end

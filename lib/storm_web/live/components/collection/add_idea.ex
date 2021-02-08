defmodule StormWeb.Live.Components.Collection.AddIdea do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button class="button" phx-click="add_idea" phx-target="<%= @myself %>">
      <span class="icon is-small">
        <i class="fas fa-plus"></i>
      </span>
      <span>Add idea</span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event(
        "add_idea",
        _value,
        socket
      ) do
    %Storm.BrowserSession{collection_id: collection_id, user_id: user_id} =
      socket |> Storm.BrowserSession.get_browser_session()

    Storm.Db.Crud.add_idea(collection_id, user_id)
    Logger.info("#{__MODULE__} idea added")

    {:noreply, socket}
  end
end

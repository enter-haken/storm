defmodule StormWeb.Live.Components.Text.Add do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <button phx-click="add_text" phx-target="<%= @myself %>" class="button">
      <span class="icon">
        <i class="fas fa-plus"></i>
      </span>
      <span>Add <%= @kind %></span>
    </button>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event(
        "add_text",
        _value,
        %{
          assigns: %{
            kind: kind,
            idea: %Storm.Idea{id: idea_id}
          }
        } = socket
      ) do
    %Storm.BrowserSession{user_id: user_id} = socket |> Storm.BrowserSession.get_browser_session()

    case kind do
      "pro" ->
        Storm.Db.Crud.add_pro(idea_id, user_id)
        Logger.info("#{__MODULE__} pro added")

      "con" ->
        Storm.Db.Crud.add_con(idea_id, user_id)
        Logger.info("#{__MODULE__} con added")

      _ ->
        Storm.Db.Crud.add_comment(idea_id, user_id)
        Logger.info("#{__MODULE__} comment added")
    end

    {:noreply, socket}
  end
end

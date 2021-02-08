defmodule StormWeb.Live.Components.Collection.User do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@user_edit_mode) do %>
      <form id="user_name_<%= @storm_collection.id %>"
      phx-submit="on_update_user" 
      phx-target="<%= @myself %>">
        <div class="field">
          <p class="control has-icons-left">
            <input class="input is-success" 
              id: "user_name_input_<%= @storm_collection.id %>"
              name="user_name" 
              type="text" 
              placeholder="What is your name?" 
              phx-hook="FocusManager"
              phx-blur="on_disable_user_edit_mode"
              phx-target="<%= @myself %>"
              value="<%= if is_nil(@active_user) do "" else @active_user.name end %>">
            <span class="icon is-small is-left">
              <i class="fas fa-user"></i>
            </span>
          </p>
        </div>
      </form>
    <% else %>
      <button class="button" phx-click="on_enable_user_edit_mode" phx-target="<%= @myself %>">
        <span class="icon is-small">
          <i class="fas fa-user"></i>
        </span>
        <span>
        <%= if is_nil(@active_user) or is_nil(@active_user.name) do %>
          What is your name?
        <% else %>
          <%= @active_user.name %>
        <% end %>
        </span>
      </button>
    <% end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(user_edit_mode: false)}
  end

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
        "on_update_user",
        %{"user_name" => user_name},
        socket
      ) do
    %Storm.BrowserSession{collection_id: collection_id, user_id: user_id} =
      socket
      |> Storm.BrowserSession.get_browser_session()

    case user_name do
      "" ->
        Storm.Db.Crud.update_user_name(user_id, nil)

      _ ->
        Storm.Db.Crud.update_user_name(user_id, user_name)
    end

    Logger.info(
      "#{__MODULE__} user name for user #{user_id} has been updated for collection #{
        collection_id
      }"
    )

    {:noreply, socket |> assign(:user_edit_mode, false)}
  end

  def handle_event(
        "on_enable_user_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:user_edit_mode, true)}
  end

  def handle_event(
        "on_disable_user_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:user_edit_mode, false)}
  end
end

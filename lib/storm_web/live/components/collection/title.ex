defmodule StormWeb.Live.Components.Collection.Title do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@title_edit_mode) do %>
      <form id="collection_form_<%= @storm_collection.id %>"
      phx-submit="on_update_title" 
      phx-target="<%= @myself %>">
        <div class="field">
          <p class="control">
            <input class="input is-success" 
              id: "collection_title_input_<%= @storm_collection.id %>"
              name="title" 
              type="text" 
              placeholder="Add collection title" 
              phx-hook="FocusManager"
              phx-blur="on_disable_title_edit_mode"
              phx-target="<%= @myself %>"
              value="<%= @storm_collection.title %>">
          </p>
        </div>
      </form>
    <% else %>
      <%= if(Storm.Collection.can_edit?(@storm_collection, @active_user)) do %>
        <a phx-click="on_enable_title_edit_mode" phx-target="<%= @myself %>">
          <h1 class="title">
            <%= if is_nil(@storm_collection.title) do %>
              Click me, to set the collection title
            <% else %>
              <%= @storm_collection.title %>
            <% end %>
          </h1>
        </a>
      <% else %> 
        <h1 class="title"> 
          <%= @storm_collection.title %>
        </h1>
      <% end %>
    <% end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(title_edit_mode: false)}
  end

  def update(
        %{
          storm_collection: storm_collection,
          active_user: active_user
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       storm_collection: storm_collection,
       active_user: active_user
     )}
  end

  def can_edit?(collection, user) do
    Storm.User.canEdit?(collection, user) and is_nil(collection.title)
  end

  def handle_event(
        "on_update_title",
        %{"title" => title},
        %{
          assigns: %{
            storm_collection: %Storm.Collection{id: collection_id}
          }
        } = socket
      ) do
    Storm.Db.Crud.update_collection_title(collection_id, title)

    {:noreply, socket |> assign(:title_edit_mode, false)}
  end

  def handle_event(
        "on_enable_title_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:title_edit_mode, true)}
  end

  def handle_event(
        "on_disable_title_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:title_edit_mode, false)}
  end
end

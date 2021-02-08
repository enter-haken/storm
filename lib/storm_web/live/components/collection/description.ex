defmodule StormWeb.Live.Components.Collection.Description do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@description_edit_mode) do %>
      <form id="collection_description_form_<%= @storm_collection.id %>"
      phx-submit="on_update_description" 
      phx-target="<%= @myself %>">
        <div class="field">
          <p class="control">
            <input class="input is-success" 
              id="collection_title_description_<%= @storm_collection.id %>"
              name="description" 
              type="text" 
              placeholder="Add collection description" 
              phx-hook="FocusManager"
              phx-blur="on_disable_description_edit_mode"
              phx-target="<%= @myself %>"
              value="<%= @storm_collection.description %>">
          </p>
        </div>
      </form>
    <% else %>
      <%= if(Storm.Collection.can_edit?(@storm_collection, @active_user)) do %>
        <a phx-click="on_enable_description_edit_mode" phx-target="<%= @myself %>">
          <h2 class="subtitle">
            <%= if is_nil(@storm_collection.description) do %>
              Click me, to set the collection description 
            <% else %>
              <%= @storm_collection.description %>
            <% end %>
          </h2>
        </p>
      <% else %> 
        <h2 class="subtitle"> 
          <%= @storm_collection.description %>
        </h2>
      <% end %>
    <% end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(description_edit_mode: false)}
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
        "on_update_description",
        %{"description" => description},
        %{
          assigns: %{
            storm_collection: %Storm.Collection{id: collection_id}
          }
        } = socket
      ) do
    Storm.Db.Crud.update_collection_description(collection_id, description)

    {:noreply, socket |> assign(:description_edit_mode, false)}
  end

  def handle_event(
        "on_enable_description_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:description_edit_mode, true)}
  end

  def handle_event(
        "on_disable_description_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:description_edit_mode, false)}
  end
end

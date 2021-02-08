defmodule StormWeb.Live.Components.Idea.Description do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@description_edit_mode) do %>
      <form id="idea_description_form_<%= @idea.id %>"
      phx-submit="on_update_description" 
      phx-target="<%= @myself %>">
        <div class="field">
          <p class="control">
            <input class="input is-success" 
              id="idea_description_input_<%= @idea.id %>"
              name="description" 
              type="text" 
              placeholder="Add idea description" 
              phx-hook="FocusManager"
              phx-blur="on_disable_description_edit_mode"
              phx-target="<%= @myself %>"
              value="<%= @idea.description %>">
          </p>
        </div>
      </form>
    <% else %>
      <%= if(Storm.Idea.can_edit?(@idea, @active_user)) do %>
        <a phx-click="on_enable_description_edit_mode" phx-target="<%= @myself %>">
          <h2 class="subtitle">
            <%= if(is_nil(@idea.description)) do %>
              Click me, to set the idea description 
            <% else %>
              <%= @idea.description %>
            <% end %>
          </h2>
        </a>
      <% else %> 
        <h2 class="subtitle"> 
          <%= @idea.description %>
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
          idea: idea,
          active_user: active_user
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       idea: idea,
       active_user: active_user
     )}
  end

  def can_edit?(idea, user) do
    Storm.User.canEdit?(idea, user)
  end

  def handle_event(
        "on_update_description",
        %{"description" => description},
        %{
          assigns: %{
            idea: %Storm.Idea{id: idea_id},
          }
        } = socket
      ) do
    Storm.Db.Crud.update_idea_description(idea_id, description)

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

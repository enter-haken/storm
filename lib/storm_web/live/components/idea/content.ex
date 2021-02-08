defmodule StormWeb.Live.Components.Idea.Content do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@title_edit_mode) do %>
      <form id="idea_content_form_<%= @idea.id %>"
      phx-submit="on_update_title" 
      phx-hook="Focus"
      phx-target="<%= @myself %>">
        <div class="field">
          <p class="control">
            <input class="input is-success" 
              id="idea_content_input_<%= @idea.id %>"
              name="content" 
              type="text" 
              placeholder="Add idea content" 
              phx-hook="FocusManager"
              phx-blur="on_disable_title_edit_mode"
              phx-target="<%= @myself %>"
              value="<%= @idea.content %>">
          </p>
        </div>
      </form>
    <% else %>
      <%= if(Storm.Idea.can_edit?(@idea, @active_user)) do %>
        <a phx-click="on_enable_title_edit_mode" phx-target="<%= @myself %>">
          <h1 class="title"> 
            <%= if is_nil(@idea.content) do %>
              Click me, to set the idea content 
            <% else %>
              <%= @idea.content %>
            <% end %>
          </h1>
        </a>
      <% else %> 
        <h1 class="title"> 
          <%= @idea.content %>
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
        "on_update_title",
        %{"content" => content},
        %{
          assigns: %{
            idea: %Storm.Idea{id: idea_id},
          }
        } = socket
      ) do
    Storm.Db.Crud.update_idea_content(idea_id, content)

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

defmodule StormWeb.Live.Components.Text.Content do
  use Phoenix.LiveComponent

  require Logger

  def render(assigns) do
    ~L"""
    <%= if(@text_edit_mode) do %>
      <article class="message <%= get_article_class(@prefix) %>">
        <div class="message-body">
          <%= if not is_nil(@prefix) do %>
            <p><b><%= @prefix %>: </b></p></p>
          <% end %>
          <form id="text_content_form_<%= @text.id %>"
            phx-submit="on_update_text" 
            phx-target="<%= @myself %>">
            <div class="field">
              <p class="control">
                <textarea class="textarea" 
                  id="text_input_<%= @text.id %>"
                  name="content" 
                  phx-hook="FocusManager"
                  placeholder="Add content"><%= @text.content %></textarea>
              </p>
            </div>
            <div class="field is-grouped">
              <div class="control">
                <button type="submit" class="button is-link">Save</button>
              </div>
              <div class="control">
                <a class="button is-link is-light" 
                  phx-click="on_disable_text_edit_mode" 
                  phx-target="<%= @myself %>">Cancel</a>
              </div>
            </div>
          </form>
        </div>
      </article>
    <% else %>
      <%= if(Storm.Text.can_edit?(@text, @active_user)) do %>
        <article class="message <%= get_article_class(@prefix) %>">
          <div class="message-body">
            <div class="field has-addons is-pulled-right">
              <p class="control">
                <button phx-click="on_enable_text_edit_mode" phx-target="<%= @myself %>" class="button">
                  <span class="icon">
                    <i class="fas fa-edit"></i>
                  </span>
                </button>
              </p>
              <p class="control">
                <button class="button" phx-click="on_toggle_visibility" phx-target="<%= @myself %>">
                  <span class="icon is-small">
                    <i class="<%= is_visible?(@text) %>"></i>
                  </span>
                </button>
              </p>
              <p class="control">
                <button phx-click="on_delete_text" phx-target="<%= @myself %>" class="button">
                  <span class="icon">
                    <i class="fas fa-trash"></i>
                  </span>
                </button>
              </p>
            </div>
            <%= if not is_nil(@prefix) do %>
              <p><b><%= @prefix %>: </b></p></p>
            <% end %>
            <p>
              <%= if(is_nil(@text.content)) do %>
                <p>
                  Please add some content. 
                </p>
                <p>
                  You can use <a href="https://daringfireball.net/projects/markdown/" target="__blank">Markdown</a> if you like.
                </p>
                <p>
                  This is <strong>not visible</strong> to other users.
                </p>
              <% else %>
                <%= @text.content |> markdown_to_html() %>
              <% end %>
            </p>
            <%= if not is_nil(@text.creator) and not is_nil(@text.creator.name) do %>
              <p>
                <i>(by <%= @text.creator.name %>)</i>
              </p>
            <% end %>
          </div>
        </article>
      <% else %> 
        <article class="message <%= get_article_class(@prefix) %>">
          <div class="message-body">
            <%= if Storm.Text.can_delete?(@text, @active_user) do %>
              <div class="field has-addons is-pulled-right">
                <p class="control">
                  <button phx-click="on_delete_text" phx-target="<%= @myself %>" class="button">
                    <span class="icon">
                      <i class="fas fa-trash"></i>
                    </span>
                  </button>
                </p>
              </div>
            <% end %>
            <%= if not is_nil(@prefix) do %>
              <p><b><%= @prefix %>: </b></p>
            <% end %>
            <%= @text.content |> markdown_to_html() %>
            <%= if not is_nil(@text.creator) and not is_nil(@text.creator.name) do %>
              <p>
                <i>(by <%= @text.creator.name %>)</i>
              </p>
            <% end %>
          </div>
        </article>
      <% end %>
    <% end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(text_edit_mode: false)}
  end

  def update(
        %{
          prefix: prefix,
          text: text,
          active_user: active_user
        } = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       prefix: prefix,
       text: text,
       active_user: active_user
     )}
  end

  def handle_event(
        "on_toggle_visibility",
        _value,
        %{
          assigns: %{
            text: %Storm.Text{
              id: text_id
            }
          }
        } = socket
      ) do
    Storm.Db.Crud.toggle_text_visibility(text_id)

    {:noreply, socket}
  end

  def handle_event(
        "on_update_text",
        %{"content" => content},
        %{
          assigns: %{
            text: %Storm.Text{id: text_id}
          }
        } = socket
      ) do
    Storm.Db.Crud.update_text(text_id, content)

    {:noreply, socket |> assign(:text_edit_mode, false)}
  end

  def handle_event(
        "on_delete_text",
        _value,
        %{
          assigns: %{
            text: %Storm.Text{id: text_id}
          }
        } = socket
      ) do
    Storm.Db.Crud.delete_text(text_id)

    {:noreply, socket}
  end

  def handle_event(
        "on_enable_text_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:text_edit_mode, true)}
  end

  def handle_event(
        "on_disable_text_edit_mode",
        _value,
        socket
      ) do
    {:noreply, socket |> assign(:text_edit_mode, false)}
  end

  def can_edit?(text, user) do
    Storm.User.canEdit?(text, user)
  end

  defp get_article_class(prefix) do
    case(prefix) do
      "pro" -> "is-success"
      "con" -> "is-danger"
      _ -> ""
    end
  end

  defp markdown_to_html(raw_markdown) do
    # REMARK:
    # HTML is valid markdown
    # -> therefore the html ast has to be checked for
    #    invalid links

    with {:ok, html, _} <- Earmark.as_html(raw_markdown),
         {:ok, html_ast} <- Floki.parse_document(html) do
      html_ast
      |> Floki.filter_out("html")
      |> Floki.filter_out("head")
      |> Floki.filter_out("body")
      |> Floki.filter_out("meta")
      |> Floki.filter_out("link")
      |> Floki.filter_out("script")
      |> Floki.find_and_update("a", fn {"a", [{"href", href}]} ->
        case validate_uri(href) do
          {:ok, url} ->
            {"a", [{"href", url}, {"target", "__blank"}]}

          _ ->
            {"a", [{"href", ""}]}
        end
      end)
      |> Floki.raw_html()
      |> Phoenix.HTML.raw()
    else
      _ ->
        raw_markdown
    end
  end

  defp validate_uri(str) do
    uri = URI.parse(str)

    case URI.parse(str) do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      _ -> {:ok, str}
    end
  end

  defp is_visible?(%Storm.Text{is_visible: is_visible}) do
    if is_visible do
      "fas fa-eye"
    else
      "fas fa-eye-slash"
    end
  end
end

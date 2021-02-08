defmodule StormWeb.IndexLive do
  use StormWeb, :live_view
  use Phoenix.HTML

  require Logger

  @pager_offset 2

  # TODO: add search bar
  # - use https://hexdocs.pm/phoenix_live_view/bindings.html#rate-limiting-events-with-debounce-and-throttle
  # - fulltext search on collection json_view

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:collections, Storm.Db.Crud.get_collection_list())
     |> assign(:storm_uuid, session["storm_uuid"])
     |> assign(:current_page, 1)
     |> assign(:active_collections, Storm.Db.Crud.get_browser_session(session["storm_uuid"]))}
  end

  @impl true
  def handle_event(
        "add_collection",
        _value,
        %{assigns: %{storm_uuid: storm_uuid}} = socket
      ) do
    %{"collection_id" => collection_id, "owner_id" => owner_id} = Storm.Db.Crud.add_collection()

    Storm.Db.Crud.add_browser_session(storm_uuid, collection_id, owner_id)

    {:noreply, push_redirect(socket, to: "/collection/#{collection_id}")}
  end

  @impl true
  def handle_event(
        "set_page_" <> page,
        _value,
        socket
      ) do
    {:noreply,
     socket |> assign(:collections, Storm.Db.Crud.get_collection_list(String.to_integer(page)))}
  end

  defp page(number, is_current) do
    assigns = %{number: number, is_current: is_current}

    ~L"""
    <li>
      <%= if (@is_current) do %>
        <a class="pagination-link is-current" phx-click="set_page_<%= @number %>"><%= @number %></a>
      <% else %>
        <a class="pagination-link" phx-click="set_page_<%= @number %>"><%= @number %></a>
      <% end %>
    </li>
    """
  end

  defp elipse(),
    do: ~E"""
    <li>
      <span class="pagination-ellipsis">&hellip;</span>
    </li>
    """

  defp is_page?(current_page, active_page, last_page) do
    range = Enum.to_list((active_page - @pager_offset)..(active_page + @pager_offset))

    range |> Enum.any?(fn x -> x == active_page end)

    cond do
      last_page < 5 ->
        true

      current_page == 1 ->
        true

      current_page == active_page ->
        true

      current_page == last_page ->
        true

      Enum.to_list((active_page - @pager_offset)..(active_page + @pager_offset))
      |> Enum.any?(fn x -> x == current_page end) ->
        true

      true ->
        false
    end
  end

  defp pages(active_page, last_page) do
    pager_pages =
      Enum.to_list(1..last_page)
      |> Enum.map(fn x ->
        case is_page?(x, active_page, last_page) do
          true ->
            %{state: :is_page, current_page: x}

          _ ->
            %{state: :is_elipse, current_page: x}
        end
      end)
    |> Enum.chunk_by(fn %{state: state} -> state == :is_elipse end)
    |> Enum.map(fn x ->
      %{state: state} = first = List.first(x)

      case state do
        :is_elipse ->
          [first]

        _ ->
          x
      end
    end)
    |> List.flatten()

    assigns = %{pager_pages: pager_pages, active_page: active_page}

    ~L"""
       <ul class="pagination-list">
         <%= for %{state: state, current_page: current_page} <- @pager_pages do %>
           <%= if(state == :is_page) do %>
             <%= page(current_page, current_page == active_page) %>
           <% else %>
             <%= elipse() %>
           <% end %>
         <% end %>
       </ul>
    """
  end

  def pager(%Storm.CollectionList{page: page, pages: pages}) do
    assigns = %{page: page, prev: page - 1, next: page + 1, pages: pages}

    ~L"""
      <nav class="pagination" role="navigation">
        <a class="pagination-previous" <%= if (@prev == 0), do: "disabled" %> phx-click="set_page_<%= @prev %>">Previous</a>
        <a class="pagination-next" <%= if (@next > @pages), do: "disabled" %> phx-click="set_page_<%= @next %>">Next page</a>
        <%= pages(page, pages) %>
      </nav>
    """
  end
end

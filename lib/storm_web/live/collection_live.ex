defmodule StormWeb.CollectionLive do
  use StormWeb, :live_view

  require Logger

  # TODO: add full text search based on @storm_collection 
  # * different color for matches (see init.sql comments)

  # TODO: add "collection delete" to collection config

  # TODO: set up active user on first visit for non owner

  # TODO: statistics: only calculate visible content

  @impl true
  def mount(_params, session, socket) do
    Logger.info("#{__MODULE__} mount with empty collection")

    {:ok,
     socket
     |> assign(:storm_collection, %Storm.Collection{})
     |> assign(:active_collections, Storm.Db.Crud.get_browser_session(session["storm_uuid"]))
     |> assign(:storm_uuid, session["storm_uuid"])
     |> assign(:active_user, nil)}
  end

  @impl true
  def handle_params(
        %{"id" => id},
        _uri,
        %{assigns: %{storm_uuid: browser_collection_id}} = socket
      ) do
    Logger.info("#{__MODULE__} register collection #{id} for broadcast")

    Registry.register(Registry.CollectionUpdater, id, [])
    Registry.register(Registry.BrowserSessionUpdater, browser_collection_id, [])

    Logger.info("#{__MODULE__} inital load collection #{id} from database")

    {:noreply,
     socket
     |> assign(:storm_collection, Storm.Db.Crud.get_collection(id))
     |> update_active_user()}
  end

  @impl true
  def handle_info({:storm_broadcast, id}, socket) do
    Logger.info("#{__MODULE__} got broadcast message for storm collection #{id}")
    {:ok, updated_collection} = Storm.CollectionWorker.get(id)

    {:noreply,
     socket
     |> assign(:storm_collection, updated_collection)
     |> update_active_user()}
  end

  @impl true
  def handle_info({:browser_session_broadcast, id}, socket) do
    Logger.info("#{__MODULE__} got broadcast message for updating browser collection id #{id}")

    {:noreply,
     socket
     |> assign(:active_collections, Storm.Db.Crud.get_browser_session(id))
     |> update_active_user()}
  end

  @impl true
  def handle_info(call, socket) do
    Logger.warn("#{__MODULE__} got message: #{inspect(call)}")
    {:noreply, socket}
  end

  defp update_active_user(
         %{
           assigns: %{
             storm_collection: %Storm.Collection{id: collection_id, users: users},
             active_collections: active_collections
           }
         } = socket
       ) do
    with %Storm.BrowserSession{user_id: user_id} <-
           active_collections
           |> Enum.find(fn %Storm.BrowserSession{collection_id: possible_collection_id} ->
             possible_collection_id == collection_id
           end),
         %Storm.User{} = user <-
           users
           |> Enum.find(fn %Storm.User{id: found_user_id} -> found_user_id == user_id end) do
      Logger.debug("#{__MODULE__} set active user #{user_id} for collection #{collection_id}")

      socket |> assign(:active_user, user)
    else
      err ->
        Logger.warn("#{__MODULE__} could not add active user #{inspect(err, pretty: true)}")
        socket
    end
  end
end

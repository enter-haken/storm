defmodule Storm.Db.Listen do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :listener)
  end

  def init(pg_config) do
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, "storm")

    Logger.info("#{__MODULE__} started.")
    Logger.info("#{__MODULE__}: listening to changes for pid #{inspect(pid)}")

    {:ok, {pid, ref}}
  end

  # TODO: add on collection delete notification
  # - redirect to index
  # - show kind of message for a few seconds

  def handle_info({:notification, _pid, _ref, "storm", collection_id}, state) do
    Logger.info("#{__MODULE__}: update collection #{collection_id}")

    if not Storm.CollectionSupervisor.any?(collection_id) do
      Logger.info("#{__MODULE__}: started new collection worker for collection #{collection_id}")
      Storm.CollectionSupervisor.add(%Storm.Collection{id: collection_id})
    end

    # TODO: check timing

    collection_id
    |> Storm.CollectionWorker.update()

    Registry.dispatch(Registry.CollectionUpdater, collection_id, fn collections ->
      for {pid, _} <- collections, do: send(pid, {:storm_broadcast, collection_id})
    end)

    {:noreply, state}
  end

  def handle_info(info, state) do
    Logger.warn("#{__MODULE__}: unhandled notification info: #{inspect(info)}")
    {:noreply, state}
  end
end

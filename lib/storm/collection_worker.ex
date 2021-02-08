defmodule Storm.CollectionWorker do
  use GenServer

  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%Storm.Collection{id: id} = state) do
    Logger.info("collection #{id} started.")

    {:ok, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:update, _from, %Storm.Collection{id: id} = _state) do
    collection = Storm.Db.Crud.get_collection(id)

    {:reply, collection, collection}
  end

  defp call(collection_id, params) do
    case collection_id |> Storm.CollectionSupervisor.get_pid() do
      {:ok, pid} ->
        {:ok, GenServer.call(pid, params)}

      _ ->
        {:error, :eworkerunknown, collection_id}
    end
  end

  def get(collection_id),
    do:
      collection_id
      |> call(:get)

  def update(collection_id),
    do:
      collection_id
      |> call(:update)
end

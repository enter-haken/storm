defmodule Storm.CollectionSupervisor do
  use Supervisor
  require Logger

  alias Storm.CollectionWorker

  def start_link(_) do
    Logger.info("#{__MODULE__} started.")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end

  def add(%Storm.Collection{id: id} = collection) do
    spec = Supervisor.child_spec({CollectionWorker, collection}, id: id)

    case __MODULE__
         |> Supervisor.start_child(spec) do
      {:ok, _pid} ->
        Logger.info("started new collection #{id}")
        {:ok, collection}

      err ->
        Logger.warn("could not start collection #{id} #{inspect(err, pretty: true)}")
        {:error, "could not start collection"}
    end
  end

  # TODO: delete collections after n hours of inactivity

  def delete(%Storm.Collection{id: id}) do
    case __MODULE__
         |> Supervisor.terminate_child(id) do
      {:error, _not_found} ->
        Logger.warn("clould not terminate child for collection #{id}.")
        {:error, :failed}

      _ ->
        Supervisor.delete_child(Storm.CollectionSupervisor, id)
        Logger.info("collection #{id} has been terminated, after two hours of inactivity.")

        {:ok, :terminated}
    end
  end

  def get_pid(id) do
    case any?(id) do
      true ->
        {_, pid, _, _} =
          Supervisor.which_children(__MODULE__)
          |> Enum.find(fn {collection_id, _, _, _} -> collection_id == id end)

        {:ok, pid}

      _ ->
        {:error, :collection_not_found}
    end
  end

  def any?(id) do
    Supervisor.which_children(__MODULE__)
    |> Enum.any?(fn {collection_id, _, _, _} -> collection_id == id end)
  end
end

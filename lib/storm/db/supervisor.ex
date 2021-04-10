defmodule Storm.Db.Supervisor do
  use Supervisor
  require Logger

  def start_link(_) do
    Logger.info("#{__MODULE__} started.")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      Storm.Db.Crud,
      Storm.Db.Listen,
      Storm.Db.ListenBrowserSession
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

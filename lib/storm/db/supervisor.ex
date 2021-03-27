defmodule Storm.Db.Supervisor do
  use Supervisor
  require Logger

  def start_link(_) do
    Logger.info("#{__MODULE__} started.")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    credentials = Application.get_env(:storm, :pg_config)

    children = [
      {Storm.Db.Listen, credentials},
      {Storm.Db.ListenBrowserSession, credentials},
      {Storm.Db.Crud, credentials}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

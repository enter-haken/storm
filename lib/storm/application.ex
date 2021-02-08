defmodule Storm.Application do
  use Application

  def start(_type, _args) do
    credentials = Application.get_env(:storm, :pg_config)

    children = [
      {Storm.Db.Listen, credentials},
      {Storm.Db.ListenBrowserSession, credentials},
      {Storm.Db.Crud, credentials},
      Storm.CollectionSupervisor,
      StormWeb.Telemetry,
      {Phoenix.PubSub, name: Storm.PubSub},
      StormWeb.Endpoint
    ]

    {:ok, _} =
      Registry.start_link(
        keys: :duplicate,
        name: Registry.CollectionUpdater,
        partitions: System.schedulers_online()
      )

    {:ok, _} =
      Registry.start_link(
        keys: :duplicate,
        name: Registry.BrowserSessionUpdater,
        partitions: System.schedulers_online()
      )

    opts = [strategy: :one_for_one, name: Storm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    StormWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

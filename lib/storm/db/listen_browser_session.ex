defmodule Storm.Db.ListenBrowserSession do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :browser_session_listener)
  end

  def init(pg_config) do
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, "browser_session")

    Logger.info("#{__MODULE__} started.")
    Logger.info("#{__MODULE__}: listening to changes for pid #{inspect(pid)}")

    {:ok, {pid, ref}}
  end

  def handle_info({:notification, _pid, _ref, "browser_session", browser_session_id}, state) do
    Logger.info("#{__MODULE__}: browser session #{browser_session_id} has been updated")

    Registry.dispatch(Registry.BrowserSessionUpdater, browser_session_id, fn sessions ->
      for {pid, _} <- sessions, do: send(pid, {:browser_session_broadcast, browser_session_id})
    end)

    {:noreply, state}
  end

  def handle_info(info, state) do
    Logger.warn("#{__MODULE__}: unhandled notification info: #{inspect(info)}")
    {:noreply, state}
  end
end

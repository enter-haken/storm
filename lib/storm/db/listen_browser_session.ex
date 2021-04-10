defmodule Storm.Db.ListenBrowserSession do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :browser_session_listener)
  end

  def init(_args) do
    {:ok, pid} =
      Application.get_env(:storm, :pg_config)
      |> Keyword.put_new(:auto_reconnect, true)
      |> Postgrex.Notifications.start_link()

    case Postgrex.Notifications.listen(pid, "browser_session") do
      {:ok, ref} ->
        Logger.info("#{__MODULE__}: listening to changes for pid #{inspect(pid)}")
        {:ok, {pid, ref}}

      {:eventually, ref} ->
        Logger.warn("#{__MODULE__}: started listener for pid #{inspect(pid)}. Some messages may be dropped.")
        {:ok, {pid, ref}}
    end
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

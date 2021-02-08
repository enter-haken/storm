defmodule Storm.DbInit do
  use ExUnit.CaseTemplate

  require Logger

  setup_all do
    Logger.info("reset test db on startup")

    reset_db()
    |> inspect()
    |> Logger.info()

    :ok
  end

  setup _tags do
    on_exit(fn ->
      Application.stop(:storm)

      Logger.info("reset test db after test case completion")

      reset_db()
      |> inspect()
      |> Logger.info()

      :ok
    end)

    Logger.info("starting storm...")
    Application.ensure_all_started(:storm)
    Logger.info("... storm has been started")

    :ok
  end

  defp bash(script), do: System.cmd("sh", ["-c", script])

  defp reset_db() do
    # TODO: try to detect, when the db is up and running
    {res, 0} = ~s(
      make -C db env=test all;
      sleep 3;
          ) |> bash()

    res |> String.split("\n") |> Enum.each(fn x -> Logger.debug("resetDb: #{x}") end)
  end

  def add_test_collection() do
    Storm.Db.Crud.add_collection()

    [
      %Storm.Collection{
        id: collection_id 
      }
    ] = Storm.Db.Crud.get_collection_list()

    %Storm.Collection{
      users: [
        %Storm.User{
          id: user_id
        }
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    {collection_id, user_id}
  end
end

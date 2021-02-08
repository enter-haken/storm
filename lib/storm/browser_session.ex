defmodule Storm.BrowserSession do
  alias __MODULE__

  require Logger

  @type t :: %BrowserSession{
          browser_session_id: String.t(),
          collection_id: String.t(),
          user_id: String.t()
        }

  defstruct browser_session_id: nil,
            collection_id: nil,
            user_id: nil

  def create(%{
        "id_browser_session" => browser_session_id,
        "id_collection" => collection_id,
        "id_user" => user_id
      }),
      do: %BrowserSession{
        browser_session_id: browser_session_id,
        collection_id: collection_id,
        user_id: user_id
      }

  def get_browser_session(%{
        assigns: %{
          storm_collection: %Storm.Collection{
            id: collection_id
          },
          active_collections: active_collections,
          storm_uuid: storm_uuid
        }
      }) do
    Logger.debug("upsert browser session...")
    Logger.debug("#{__MODULE__} active_collections: #{inspect(active_collections, pretty: true)}")
    Logger.debug("#{__MODULE__} storm_uuid: #{inspect(storm_uuid, pretty: true)}")

    case active_collections
         |> Enum.find(fn %BrowserSession{collection_id: possible_collection_id} ->
           possible_collection_id == collection_id
         end) do
      %BrowserSession{user_id: user_id} = browser_session ->
        Logger.info("#{__MODULE__} found user #{user_id} in collection #{collection_id}")

        browser_session

      _ ->
        Logger.info("#{__MODULE__} collection #{collection_id} not found in browser_session")
        Logger.info("#{__MODULE__} create new user...")

        user_id =
          Storm.Db.Crud.add_user(collection_id)
          |> UUID.binary_to_string!()

        Logger.info("#{__MODULE__} added user #{user_id} to collection #{collection_id}")

        Storm.Db.Crud.add_browser_session(storm_uuid, collection_id, user_id)

        Logger.info(
          "#{__MODULE__} added user #{user_id} for collection #{collection_id} to browser_session #{
            storm_uuid
          }"
        )

        %BrowserSession{
          browser_session_id: storm_uuid,
          collection_id: collection_id,
          user_id: user_id
        }
    end
  end

  def any?(active_collections, %Storm.Collection{id: collection_id}),
    do:
      active_collections
      |> Enum.any?(fn %Storm.BrowserSession{collection_id: own_collection_id} ->
        own_collection_id == collection_id
      end)
end

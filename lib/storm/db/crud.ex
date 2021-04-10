defmodule Storm.Db.Crud do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :crud)
  end

  def init(_args) do
    {:ok, pid} = 
      Application.get_env(:storm, :pg_config)
      |> Postgrex.start_link()

    Logger.info("#{__MODULE__} started.")
    Logger.info("#{__MODULE__}: listening to changes for pid #{inspect(pid)}")

    {:ok, pid}
  end

  defp log_db_messages(messages),
    do:
      messages
      |> Enum.each(fn %{message: message} ->
        Logger.debug("#{__MODULE__} db message: #{message}")
      end)

  defp execute(state, query, params \\ []) do
    case Postgrex.transaction(state, fn conn ->
           Postgrex.query!(conn, query, params)
         end) do
      {:ok,
       %Postgrex.Result{
         messages: messages,
         num_rows: 1,
         rows: [[result]]
       }} ->
        Logger.debug("#{__MODULE__}: execute \"#{inspect(query)}\"")
        Logger.debug("#{__MODULE__}: got result #{inspect(result, pretty: true)}")

        log_db_messages(messages)
        {:reply, result, state}

      {:error, error} ->
        Logger.error("#{__MODULE__} db error: #{inspect(error)}")
        {:stop, error, state}

      err ->
        Logger.error("#{__MODULE__}: unexpected db error: #{inspect(err, pretty: true)}")
        {:stop, :eunknown, state}
    end
  end

  defp get_list(state, query, params) do
    case Postgrex.query(state, query, params) do
      {:ok,
       %Postgrex.Result{
         rows: [[nil]]
       }} ->
        {:reply, [], state}

      {:ok,
       %Postgrex.Result{
         messages: messages,
         rows: [[result]]
       }} ->
        log_db_messages(messages)

        {:reply, result, state}

      {:error, error} ->
        Logger.error("db error: #{inspect(error)}")
        {:stop, error, state}

      _ ->
        Logger.error("unkown db error")
        {:stop, :eunknown, state}
    end
  end

  def handle_call(:add_collection, _from, state), do: execute(state, "SELECT insert_collection()")

  def handle_call({:get_collection, id}, _from, state),
    do: execute(state, "SELECT get_collection($1)", [id |> UUID.string_to_binary!()])

  def handle_call({:toggle_collection_visibility, id}, _from, state),
    do:
      execute(state, "SELECT toggle_collection_visibility($1)", [id |> UUID.string_to_binary!()])

  def handle_call({:delete_collection, id}, _from, state),
    do: execute(state, "SELECT delete_collection($1)", [id |> UUID.string_to_binary!()])

  def handle_call(
        {:add_browser_session, browser_session_id, collection_id, user_id},
        _from,
        state
      ),
      do:
        execute(state, "SELECT insert_browser_session($1,$2,$3)", [
          browser_session_id |> UUID.string_to_binary!(),
          collection_id |> UUID.string_to_binary!(),
          user_id |> UUID.string_to_binary!()
        ])

  def handle_call({:get_browser_session, browser_session_id}, _from, state),
    do:
      get_list(state, "SELECT get_browser_session($1)", [
        browser_session_id |> UUID.string_to_binary!()
      ])

  def handle_call({:get_collection_list, page, page_size}, _from, state),
    do: execute(state, "SELECT get_collections($1,$2)", [page, page_size])

  def handle_call({:update_collection_title, id, title}, _from, state),
    do:
      execute(state, "SELECT update_collection_title($1,$2)", [
        id |> UUID.string_to_binary!(),
        title
      ])

  def handle_call({:update_collection_description, id, description}, _from, state),
    do:
      execute(state, "SELECT update_collection_description($1,$2)", [
        id |> UUID.string_to_binary!(),
        description
      ])

  def handle_call({:add_user, collection_id}, _from, state),
    do: execute(state, "SELECT insert_user($1)", [collection_id |> UUID.string_to_binary!()])

  def handle_call({:delete_user, user_id}, _from, state),
    do: execute(state, "SELECT delete_user($1)", [user_id |> UUID.string_to_binary!()])

  def handle_call({:update_user_name, user_id, name}, _from, state),
    do:
      execute(state, "SELECT update_user_name($1, $2)", [
        user_id |> UUID.string_to_binary!(),
        name
      ])

  def handle_call({:add_idea, collection_id, creator_id}, _from, state),
    do:
      execute(state, "SELECT insert_idea($1,$2)", [
        collection_id |> UUID.string_to_binary!(),
        creator_id |> UUID.string_to_binary!()
      ])

  def handle_call({:toggle_idea_visibility, idea_id}, _from, state),
    do:
      execute(state, "SELECT toggle_idea_visibility($1)", [
        idea_id |> UUID.string_to_binary!()
      ])

  def handle_call({:delete_idea, idea_id}, _from, state),
    do:
      execute(state, "SELECT delete_idea($1)", [
        idea_id |> UUID.string_to_binary!()
      ])

  def handle_call({:update_idea_content, idea_id, content}, _from, state),
    do:
      execute(state, "SELECT update_idea_content($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        content
      ])

  def handle_call({:update_idea_description, idea_id, description}, _from, state),
    do:
      execute(state, "SELECT update_idea_description($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        description
      ])

  def handle_call({:add_like, idea_id, user_id}, _from, state),
    do:
      execute(state, "SELECT insert_like($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        user_id |> UUID.string_to_binary!()
      ])

  def handle_call({:delete_like, idea_id, user_id}, _from, state),
    do:
      execute(state, "SELECT delete_like($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        user_id |> UUID.string_to_binary!()
      ])

  def handle_call({:add_pro, idea_id, creator_id}, _from, state),
    do:
      execute(state, "SELECT insert_pro($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        creator_id |> UUID.string_to_binary!()
      ])

  def handle_call({:add_con, idea_id, creator_id}, _from, state),
    do:
      execute(state, "SELECT insert_con($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        creator_id |> UUID.string_to_binary!()
      ])

  def handle_call({:add_comment, idea_id, creator_id}, _from, state),
    do:
      execute(state, "SELECT insert_comment($1,$2)", [
        idea_id |> UUID.string_to_binary!(),
        creator_id |> UUID.string_to_binary!()
      ])

  def handle_call({:toggle_text_visibility, text_id}, _from, state),
    do:
      execute(state, "SELECT toggle_text_visibility($1)", [
        text_id |> UUID.string_to_binary!()
      ])

  def handle_call({:update_text, text_id, content}, _from, state),
    do:
      execute(state, "SELECT update_text($1,$2)", [
        text_id |> UUID.string_to_binary!(),
        content
      ])

  def handle_call({:delete_text, text_id}, _from, state),
    do:
      execute(state, "SELECT delete_text($1)", [
        text_id |> UUID.string_to_binary!()
      ])

  def handle_info(info, state) do
    Logger.warn("info: #{inspect(info)}")
    Logger.warn("info: #{inspect(state)}")
    {:noreply, state}
  end

  #
  # client
  #
  def sql(query, params), do: GenServer.call(:crud, {:sql, query, params})

  def add_collection(), do: GenServer.call(:crud, :add_collection)

  def get_collection_list(page \\ 1, page_size \\ 20),
    do:
      GenServer.call(:crud, {:get_collection_list, page, page_size})
      |> Storm.CollectionList.create()
      #|> Enum.map(fn raw_collection -> Storm.Collection.create(raw_collection) end)

  def get_collection(id),
    do: GenServer.call(:crud, {:get_collection, id}) |> Storm.Collection.create()

  def delete_collection(id), do: GenServer.call(:crud, {:delete_collection, id})

  def toggle_collection_visibility(id),
    do: GenServer.call(:crud, {:toggle_collection_visibility, id})

  def update_collection_title(id, title),
    do: GenServer.call(:crud, {:update_collection_title, id, title |> set_nil_if_empty()})

  def update_collection_description(id, description),
    do:
      GenServer.call(
        :crud,
        {:update_collection_description, id, description |> set_nil_if_empty()}
      )

  def add_browser_session(browser_session_id, collection_id, user_id),
    do: GenServer.call(:crud, {:add_browser_session, browser_session_id, collection_id, user_id})

  def get_browser_session(browser_session_id),
    do:
      GenServer.call(:crud, {:get_browser_session, browser_session_id})
      |> Enum.map(fn x -> Storm.BrowserSession.create(x) end)

  def add_user(collection_id), do: GenServer.call(:crud, {:add_user, collection_id})

  def delete_user(user_id), do: GenServer.call(:crud, {:delete_user, user_id})

  def update_user_name(user_id, name),
    do: GenServer.call(:crud, {:update_user_name, user_id, name |> set_nil_if_empty()})

  def add_idea(collection_id, creator_id),
    do: GenServer.call(:crud, {:add_idea, collection_id, creator_id})

  def toggle_idea_visibility(idea_id),
    do: GenServer.call(:crud, {:toggle_idea_visibility, idea_id})

  def delete_idea(idea_id),
    do: GenServer.call(:crud, {:delete_idea, idea_id})

  def update_idea_content(idea_id, content),
    do: GenServer.call(:crud, {:update_idea_content, idea_id, content |> set_nil_if_empty()})

  def update_idea_description(idea_id, description),
    do:
      GenServer.call(
        :crud,
        {:update_idea_description, idea_id, description |> set_nil_if_empty()}
      )

  def add_like(idea_id, user_id),
    do: GenServer.call(:crud, {:add_like, idea_id, user_id})

  def delete_like(idea_id, user_id),
    do: GenServer.call(:crud, {:delete_like, idea_id, user_id})

  def add_pro(idea_id, creator_id),
    do: GenServer.call(:crud, {:add_pro, idea_id, creator_id})

  def add_con(idea_id, creator_id),
    do: GenServer.call(:crud, {:add_con, idea_id, creator_id})

  def add_comment(idea_id, creator_id),
    do: GenServer.call(:crud, {:add_comment, idea_id, creator_id})

  def update_text(text_id, content),
    do: GenServer.call(:crud, {:update_text, text_id, content |> set_nil_if_empty()})

  def toggle_text_visibility(text_id),
    do: GenServer.call(:crud, {:toggle_text_visibility, text_id})

  def delete_text(text_id),
    do: GenServer.call(:crud, {:delete_text, text_id})

  defp set_nil_if_empty(text) do
    case(text) do
      "" ->
        nil

      _ ->
        text
    end
  end
end

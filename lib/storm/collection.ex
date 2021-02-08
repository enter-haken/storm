defmodule Storm.Collection do
  alias __MODULE__

  require Logger

  alias Storm.Idea
  alias Storm.User

  # TODO: add max collection age in days

  @type t :: %Collection{
          id: String.t(),
          users: [User.t()],
          title: String.t(),
          description: String.t(),
          is_visible: boolean(),
          ideas: [Idea.t()],
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct id: nil,
            title: nil,
            description: nil,
            is_visible: nil,
            users: [],
            ideas: [],
            created_at: nil,
            updated_at: nil

  def create(%{"is_dirty" => true}), do: %Collection{}

  def create(%{
        "id" => id,
        "title" => title,
        "description" => description,
        "is_visible" => is_visible,
        "users" => users,
        "ideas" => ideas
      }),
      do: %Collection{
        id: id,
        title: title,
        description: description,
        is_visible: is_visible,
        users: Enum.map(users, fn x -> Storm.User.create(x) end),
        ideas: Enum.map(ideas, fn x -> Storm.Idea.create(x) end)
      }

  def create(%{
        "id" => id,
        "title" => title,
        "description" => description,
        "is_visible" => is_visible
      }),
      do: %Collection{
        id: id,
        title:
          case is_nil(title) do
            true -> "tba"
            _ -> title
          end,
        description: description,
        is_visible: is_visible
      }

  def pros_count(%Collection{ideas: ideas}),
    do:
      ideas
      |> Enum.map(fn %Idea{pros: pros} -> length(pros) end)
      |> Enum.sum()

  def cons_count(%Collection{ideas: ideas}),
    do:
      ideas
      |> Enum.map(fn %Idea{cons: cons} -> length(cons) end)
      |> Enum.sum()

  def likes_count(%Collection{ideas: ideas}),
    do:
      ideas
      |> Enum.map(fn %Idea{likes: likes} -> length(likes) end)
      |> Enum.sum()

  def comments_count(%Collection{ideas: ideas}),
    do:
      ideas
      |> Enum.map(fn %Idea{comments: comments} -> length(comments) end)
      |> Enum.sum()

  def can_edit?(_collection, %User{is_owner: true}), do: true

  def can_edit?(_, _), do: false

  def is_visible?(active_collections, %Collection{is_visible: false} = collection),
    do: active_collections |> Storm.BrowserSession.any?(collection)

  def is_visible?(active_collections, %Collection{is_visible: true, title: nil} = collection),
    do: active_collections |> Storm.BrowserSession.any?(collection)

  def is_visible?(_active_collections, %Collection{is_visible: true}), do: true
end

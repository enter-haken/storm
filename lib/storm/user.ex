defmodule Storm.User do
  alias __MODULE__

  @type t :: %User{
          id: String.t(),
          name: String.t(),
          show_identity: boolean(),
          is_owner: boolean(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct id: nil,
            name: "anonymous",
            is_owner: false,
            show_identity: false,
            created_at: nil,
            updated_at: nil

  def create(%{
        "id" => id,
        "name" => name,
        "show_identity" => show_identity,
        "is_owner" => is_owner
      }),
      do: %User{
        id: id,
        is_owner: is_owner,
        name: name,
        show_identity: show_identity
      }

  def canEdit?(_collection_creator_can_edit_everything, %User{is_owner: true}), do: true

  def is_owner?(%User{is_owner: true}), do: true

  def is_owner?(_), do: false
end

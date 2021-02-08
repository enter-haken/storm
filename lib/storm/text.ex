defmodule Storm.Text do
  alias __MODULE__
  alias Storm.User

  @type t :: %Text{
          id: String.t(),
          content: String.t(),
          is_visible: boolean(),
          creator: User.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct id: nil,
            content: nil,
            is_visible: false,
            creator: nil,
            created_at: nil,
            updated_at: nil

  def create(%{
        "id" => id,
        "content" => content,
        "is_visible" => is_visible,
        "creator" => creator
      }),
      do: %Text{
        id: id,
        content: content,
        is_visible: is_visible,
        creator: User.create(creator)
      }

  def is_empty?(%Text{content: nil}), do: true
  def is_empty?(%Text{} = _every_thing_else), do: false

  def is_visible?(
        %Text{
          is_visible: true
        } = text,
        active_user
      ) do
    User.is_owner?(active_user) or not Text.is_empty?(text)
  end

  def is_visible?(
        %Text{
          creator: %Storm.User{
            id: user_id
          },
          is_visible: false
        },
        %Storm.User{
          id: active_user_id
        }
      ) do
    user_id == active_user_id
  end

  def is_visible?(_, _), do: false

  def can_edit?(
        %Text{
          creator: %User{
            id: creator_id
          }
        },
        %User{
          id: current_user_id
        }
      ),
      do: creator_id == current_user_id

  def can_edit?(_, _), do: false

  def can_delete?(%Text{} = _text_to_check, nil), do: false

  def can_delete?(%Text{} = _text_to_check, %Storm.User{is_owner: true}), do: true

  def can_delete?(
        %Text{
          creator: %Storm.User{
            id: user_id
          }
        },
        %Storm.User{
          id: active_user_id
        }
      ) do
    user_id == active_user_id
  end

  def can_delete?(_, _), do: false
end

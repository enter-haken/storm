defmodule Storm.Idea do
  alias __MODULE__
  alias Storm.User
  alias Storm.Text

  @type t :: %Idea{
          id: String.t(),
          creator: User.t(),
          content: String.t(),
          description: String.t(),
          is_visible: boolean(),
          comments: [Text.t()],
          pros: [Text.t()],
          cons: [Text.t()],
          likes: [User.t()],
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct id: nil,
            creator: nil,
            content: nil,
            description: nil,
            is_visible: false,
            comments: [],
            pros: [],
            cons: [],
            likes: [],
            created_at: nil,
            updated_at: nil

  def create(%{"is_dirty" => true}), do: %Idea{}

  def create(%{
        "id" => id,
        "content" => content,
        "description" => description,
        "is_visible" => is_visible,
        "pros" => pros,
        "cons" => cons,
        "comments" => comments,
        "likes" => likes,
        "creator" => creator
      }),
      do: %Idea{
        id: id,
        content: content,
        description: description,
        is_visible: is_visible,
        pros: Enum.map(pros, fn x -> Text.create(x) end),
        cons: Enum.map(cons, fn x -> Text.create(x) end),
        comments: Enum.map(comments, fn x -> Text.create(x) end),
        likes: Enum.map(likes, fn x -> User.create(x) end),
        creator: User.create(creator)
      }

  def is_empty?(%Idea{content: nil}), do: true
  def is_empty?(%Idea{} = _every_thing_else), do: false

  def is_visible?(
        %Idea{
          creator: %Storm.User{
            id: user_id
          }
        } = idea,
        %Storm.User{
          id: active_user_id
        } = active_user
      ) do
    User.is_owner?(active_user) or user_id == active_user_id or not Idea.is_empty?(idea)
  end

  def is_visible?(%Idea{is_visible: is_visible} = idea, _user) do
    is_visible and not Idea.is_empty?(idea)  
  end

  def is_visible?(_idea, _user) do
    false
  end

  def can_like?(
        %Storm.Idea{
          creator: %User{
            id: creator_id
          }
        },
        %User{
          id: current_user_id
        }
      ),
      do: creator_id != current_user_id

  def can_like?(_, _), do: false

  def can_edit?(
        %Storm.Idea{
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

  def can_delete?(%Idea{} = _idea_to_check, nil), do: false

  def can_delete?(%Idea{} = _idea_to_check, %Storm.User{is_owner: true}), do: true

  def can_delete?(
        %Idea{
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

defmodule Storm.CollectionList do
  alias __MODULE__
  require Logger

  @type t :: %CollectionList{
          collections: [Storm.Collection.t()],
          page: integer(),
          pages: integer(),
          page_size: integer(),
          total: integer()
        }

  defstruct collections: [], page: nil, pages: nil, page_size: nil, total: nil

  # this case happens, when the server is startet for the first time
  # and there are no collections yet.

  def create(%{
        "collections" => nil,
        "page" => page,
        "page_size" => page_size,
        "total" => total
      }),
      do: %CollectionList{
        collections: [],
        page: page,
        page_size: page_size,
        total: total,
        pages:
          case total do
            0 -> 1
            _ -> Kernel.ceil(total / page_size)
          end
      }

  def create(%{
        "collections" => collections,
        "page" => page,
        "page_size" => page_size,
        "total" => total
      }),
      do: %CollectionList{
        collections: collections |> Enum.map(fn x -> Storm.Collection.create(x) end),
        page: page,
        pages:
          case total do
            0 -> 1
            _ -> Kernel.ceil(total / page_size)
          end,
        page_size: page_size,
        total: total
      }
end

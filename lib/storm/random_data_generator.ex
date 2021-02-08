defmodule Storm.RandomDataGenerator do
  require Logger

  alias Storm.Db.Crud

  def create(pages \\ 1) do
    Enum.to_list(1..(20 * pages))
    |> Enum.map(fn _x ->
      Task.async(fn ->
        create_collection(true)
      end)
    end)
    |> Enum.each(fn x -> Task.await(x, 240_000) end)
  end

  defp create_collection(is_async) do
    %{"collection_id" => collection_id} = Crud.add_collection()
    Crud.toggle_collection_visibility(collection_id)
    Crud.update_collection_title(collection_id, short())
    Crud.update_collection_description(collection_id, short())

    case is_async do
      true ->
        Enum.to_list(1..Enum.random(1..10))
        |> Enum.map(fn _x ->
          Task.async(fn ->
            collection_id
            |> create_idea()
          end)
        end)
        |> Enum.each(fn x -> Task.await(x, 110_000) end)

      _ ->
        Enum.to_list(1..Enum.random(1..10))
        |> Enum.map(fn _x ->
          collection_id
          |> create_idea()
        end)
    end
  end

  defp create_user(collection_id) do
    id =
      Crud.add_user(collection_id)
      |> UUID.binary_to_string!()

    Crud.update_user_name(id, name())
    id
  end

  defp create_idea(collection_id) do
    id =
      Crud.add_idea(collection_id, create_user(collection_id))
      |> UUID.binary_to_string!()
      |> Crud.update_idea_content(short())
      |> UUID.binary_to_string!()
      |> Crud.update_idea_description(short())
      |> UUID.binary_to_string!()
      |> Crud.toggle_idea_visibility()
      |> UUID.binary_to_string!()

    Crud.add_like(id, create_user(collection_id))
    Crud.add_like(id, create_user(collection_id))
    Crud.add_like(id, create_user(collection_id))
    Crud.add_like(id, create_user(collection_id))
    create_pro(id, create_user(collection_id))
    create_pro(id, create_user(collection_id))
    create_con(id, create_user(collection_id))
    create_con(id, create_user(collection_id))
    create_comment(id, create_user(collection_id))
    create_comment(id, create_user(collection_id))
    create_comment(id, create_user(collection_id))
  end

  defp create_pro(idea_id, user_id) do
    Crud.add_pro(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Crud.update_text(long())
    |> UUID.binary_to_string!()
    |> Crud.toggle_text_visibility()
  end

  defp create_con(idea_id, user_id) do
    Crud.add_con(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Crud.update_text(long())
    |> UUID.binary_to_string!()
    |> Crud.toggle_text_visibility()
  end

  defp create_comment(idea_id, user_id) do
    Crud.add_comment(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Crud.update_text(middle())
    |> UUID.binary_to_string!()
    |> Crud.toggle_text_visibility()
  end

  defp name(),
    do:
      [
        "Abigail",
        "Alexandra",
        "Alison",
        "Amanda",
        "Amelia",
        "Amy",
        "Andrea",
        "Angela",
        "Anna",
        "Anne",
        "Audrey",
        "Ava",
        "Bella",
        "Bernadette",
        "Carol",
        "Caroline",
        "Carolyn",
        "Chloe",
        "Claire",
        "Deirdre",
        "Diana",
        "Diane",
        "Donna",
        "Dorothy",
        "Elizabeth",
        "Ella",
        "Emily",
        "Emma",
        "Faith",
        "Felicity",
        "Fiona",
        "Gabrielle",
        "Grace",
        "Hannah",
        "Heather",
        "Irene",
        "Jan",
        "Jane",
        "Jasmine",
        "Jennifer",
        "Jessica",
        "Joan",
        "Joanne",
        "Julia",
        "Karen",
        "Katherine",
        "Kimberly",
        "Kylie",
        "Lauren",
        "Leah",
        "Lillian",
        "Lily",
        "Lisa",
        "Madeleine",
        "Maria",
        "Mary",
        "Megan",
        "Melanie",
        "Michelle",
        "Molly",
        "Natalie",
        "Nicola",
        "Olivia",
        "Penelope",
        "Pippa",
        "Rachel",
        "Rebecca",
        "Rose",
        "Ruth",
        "Sally",
        "Samantha",
        "Sarah",
        "Sonia",
        "Sophie",
        "Stephanie",
        "Sue",
        "Theresa",
        "Tracey",
        "Una",
        "Vanessa",
        "Victoria",
        "VirginiaA",
        "Wanda",
        "Wendy",
        "Yvonne",
        "Zoe"
      ]
      |> Enum.shuffle()
      |> List.first()

  defp long(),
    do:
      [
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Phasellus hendrerit. Pellentesque aliquet nibh nec urna. In nisi neque, aliquet vel, dapibus id, mattis vel, nisi. Sed pretium, ligula sollicitudin laoreet viverra, tortor libero sodales leo, eget blandit nunc tortor eu nibh. Nullam mollis. Ut justo. Suspendisse potenti.",
        "Sed egestas, ante et vulputate volutpat, eros pede semper est, vitae luctus metus libero eu augue. Morbi purus libero, faucibus adipiscing, commodo quis, gravida id, est. Sed lectus. Praesent elementum hendrerit tortor. Sed semper lorem at felis. Vestibulum volutpat, lacus a ultrices sagittis, mi neque euismod dui, eu pulvinar nunc sapien ornare nisl. Phasellus pede arcu, dapibus eu, fermentum et, dapibus sed, urna.",
        "Morbi interdum mollis sapien. Sed ac risus. Phasellus lacinia, magna a ullamcorper laoreet, lectus arcu pulvinar risus, vitae facilisis libero dolor a purus. Sed vel lacus. Mauris nibh felis, adipiscing varius, adipiscing in, lacinia vel, tellus. Suspendisse ac urna. Etiam pellentesque mauris ut lectus. Nunc tellus ante, mattis eget, gravida vitae, ultricies ac, leo. Integer leo pede, ornare a, lacinia eu, vulputate vel, nisl.",
        "Suspendisse mauris. Fusce accumsan mollis eros. Pellentesque a diam sit amet mi ullamcorper vehicula. Integer adipiscing risus a sem. Nullam quis massa sit amet nibh viverra malesuada. Nunc sem lacus, accumsan quis, faucibus non, congue vel, arcu. Ut scelerisque hendrerit tellus. Integer sagittis. Vivamus a mauris eget arcu gravida tristique. Nunc iaculis mi in ante. Vivamus imperdiet nibh feugiat est.",
        "Ut convallis, sem sit amet interdum consectetuer, odio augue aliquam leo, nec dapibus tortor nibh sed augue. Integer eu magna sit amet metus fermentum posuere. Morbi sit amet nulla sed dolor elementum imperdiet. Quisque fermentum. Cum sociis natoque penatibus et magnis xdis parturient montes, nascetur ridiculus mus. Pellentesque adipiscing eros ut libero. Ut condimentum mi vel tellus. Suspendisse laoreet. Fusce ut est sed dolor gravida convallis. Morbi vitae ante. Vivamus ultrices luctus nunc. Suspendisse et dolor. Etiam dignissim. Proin malesuada adipiscing lacus. Donec metus. Curabitur gravida"
      ]
      |> Enum.shuffle()
      |> List.first()

  defp middle(),
    do:
      [
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.",
        "Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.",
        "Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.",
        "Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.",
        "Phasellus ultrices nulla quis nibh. Quisque a lectus. Donec consectetuer ligula vulputate sem tristique cursus. Nam nulla quam, gravida non, commodo a, sodales sit amet, nisi."
      ]
      |> Enum.shuffle()
      |> List.first()

  defp short(),
    do:
      [
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.",
        "Aliquam tincidunt mauris eu risus.",
        "Vestibulum auctor dapibus neque.",
        "Nunc dignissim risus id metus.",
        "Cras ornare tristique elit.",
        "Vivamus vestibulum ntulla nec ante.",
        "Praesent placerat risus quis eros.",
        "Fusce pellentesque suscipit nibh.",
        "Integer vitae libero ac risus egestas placerat.",
        "Vestibulum commodo felis quis tortor.",
        "Ut aliquam sollicitudin leo.",
        "Cras iaculis ultricies nulla.",
        "Donec quis dui at dolor tempor interdum."
      ]
      |> Enum.shuffle()
      |> List.first()
end

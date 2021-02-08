defmodule Storm.IdeaTest do
  use Storm.DbInit

  require Logger

  test "add idea" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_idea(collection_id, user_id)
    |> UUID.binary_to_string!()

    %Storm.Collection{
      ideas: ideas
    } = Storm.Db.Crud.get_collection(collection_id)

    assert length(ideas) == 1
  end

  test "delete idea" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_idea(collection_id, user_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{id: idea_id}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    Storm.Db.Crud.delete_idea(idea_id)

    %Storm.Collection{
      ideas: ideas
    } = Storm.Db.Crud.get_collection(collection_id)

    assert 0 == length(ideas)
  end

  test "update idea content" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_idea(collection_id, user_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{id: idea_id}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    Storm.Db.Crud.update_idea_content(idea_id, "updated content")

    %Storm.Collection{
      ideas: [
        %Storm.Idea{content: content}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert "updated content" == content
  end

  test "update idea description" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_idea(collection_id, user_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{id: idea_id}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    Storm.Db.Crud.update_idea_description(idea_id, "updated description")

    %Storm.Collection{
      ideas: [
        %Storm.Idea{description: description}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert "updated description" == description
  end
end

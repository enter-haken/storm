defmodule Storm.CollectionTest do
  use Storm.DbInit

  require Logger

  test "get empty collection list" do
    collections = Storm.Db.Crud.get_collection_list()

    assert [] == collections
  end

  test "add collection" do
    Storm.Db.Crud.add_collection()

    [
      %Storm.Collection{
        id: id
      }
    ] = Storm.Db.Crud.get_collection_list()

    %Storm.Collection{
      id: new_id,
      ideas: ideas,
      users: users
    } = Storm.Db.Crud.get_collection(id)

    assert id == new_id
    assert length(ideas) == 0
    assert length(users) == 1
  end

  test "delete collection" do
    Storm.Db.Crud.add_collection()

    [
      %Storm.Collection{
        id: id
      }
    ] = Storm.Db.Crud.get_collection_list()

    %Storm.Collection{
      id: new_id
    } = Storm.Db.Crud.get_collection(id)

    assert id == new_id
  end

  test "update collection title" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.update_collection_title(collection_id, "test title")

    %Storm.Collection{
      title: title
    } = Storm.Db.Crud.get_collection(collection_id)

    assert "test title" == title
  end

  test "update collection description" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.update_collection_description(collection_id, "test description")

    %Storm.Collection{
      description: description 
    } = Storm.Db.Crud.get_collection(collection_id)

    assert "test description" == description 
  end

end

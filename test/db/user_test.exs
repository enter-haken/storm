defmodule Storm.UserTest do
  use Storm.DbInit

  require Logger

  test "add user" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_user(collection_id)
    |> UUID.binary_to_string!()
    |> Logger.info()

    %Storm.Collection{
      users: users
    } = Storm.Db.Crud.get_collection(collection_id)

    assert length(users) == 2
  end

  test "update user name" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    newUser =
      Storm.Db.Crud.add_user(collection_id)
      |> UUID.binary_to_string!()

    Storm.Db.Crud.update_user_name(newUser, "newName")

    %Storm.Collection{
      users: [_, %Storm.User{name: name}]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert name == "newName"
  end

  test "delete user" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_user(collection_id)

    %Storm.Collection{
      users: [
        %Storm.User{is_owner: true},
        %Storm.User{id: id_to_delete}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    Storm.Db.Crud.delete_user(id_to_delete)

    %Storm.Collection{
      users: users
    } = Storm.Db.Crud.get_collection(collection_id)

    assert 1 == length(users)
  end

  test "delete user with content" do
    {collection_id, _user_id} = Storm.DbInit.add_test_collection()

    Storm.Db.Crud.add_user(collection_id)
    |> UUID.binary_to_string!()
    |> Logger.info()

    %Storm.Collection{
      users: [
        %Storm.User{id: owner_id, is_owner: true},
        %Storm.User{id: user_id_to_delete}
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    idea_id =
      Storm.Db.Crud.add_idea(collection_id, user_id_to_delete)
      |> UUID.binary_to_string!()
      |> Storm.Db.Crud.update_idea_content("Test idea")
      |> UUID.binary_to_string!()
      |> Storm.Db.Crud.update_idea_description("Test desc")
      |> UUID.binary_to_string!()

    idea_id_from_owner =
      Storm.Db.Crud.add_idea(collection_id, owner_id)
      |> UUID.binary_to_string!()
      |> Storm.Db.Crud.update_idea_content("Test idea owner")
      |> UUID.binary_to_string!()
      |> Storm.Db.Crud.update_idea_description("Test desc owner")
      |> UUID.binary_to_string!()

    Storm.Db.Crud.add_pro(idea_id, user_id_to_delete)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("pro")

    Storm.Db.Crud.add_con(idea_id, user_id_to_delete)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("con")

    Storm.Db.Crud.add_comment(idea_id, user_id_to_delete)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("comment")

    Storm.Db.Crud.add_comment(idea_id, owner_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("owner comment")

    Storm.Db.Crud.add_pro(idea_id_from_owner, owner_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("pro owner")

    Storm.Db.Crud.add_pro(idea_id_from_owner, user_id_to_delete)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("pro user to delete")

    Storm.Db.Crud.add_con(idea_id_from_owner, owner_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("con owner")

    Storm.Db.Crud.add_comment(idea_id_from_owner, owner_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("comment owner")

    %Storm.Collection{
      ideas:
        [
          _,
          %Storm.Idea{
            pros: pros_before_delete,
            cons: cons_before_delete,
            comments: comments_before_delete
          }
        ] = ideas_before_delete,
      users: users_before_delete
    } = Storm.Db.Crud.get_collection(collection_id)

    assert 2 == length(ideas_before_delete)
    assert 2 == length(users_before_delete)

    assert 2 == length(pros_before_delete)
    assert 1 == length(cons_before_delete)
    assert 1 == length(comments_before_delete)

    Storm.Db.Crud.delete_user(user_id_to_delete)

    %Storm.Collection{
      ideas:
        [
          %Storm.Idea{
            pros: pros_after_delete,
            cons: cons_after_delete,
            comments: comments_after_delete
          }
        ] = ideas_after_delete,
      users: users_after_delete
    } = Storm.Db.Crud.get_collection(collection_id)

    assert 1 == length(users_after_delete)
    assert 1 == length(ideas_after_delete)

    assert 1 == length(pros_after_delete)
    assert 1 == length(cons_after_delete)
    assert 1 == length(comments_after_delete)
  end
end

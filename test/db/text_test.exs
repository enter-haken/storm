defmodule Storm.TextTest do
  use Storm.DbInit

  require Logger

  test "add text" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    idea_id =
      Storm.Db.Crud.add_idea(collection_id, user_id)
      |> UUID.binary_to_string!()

    Storm.Db.Crud.add_pro(idea_id, user_id)
    Storm.Db.Crud.add_con(idea_id, user_id)
    Storm.Db.Crud.add_comment(idea_id, user_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{
          pros: [
            %Storm.Text{
              content: pro_content
            }
          ],
          cons: [
            %Storm.Text{
              content: con_content
            }
          ],
          comments: [
            %Storm.Text{
              content: comment_content
            }
          ]
        }
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert pro_content == nil
    assert con_content == nil
    assert comment_content == nil
  end

  test "update text" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    idea_id =
      Storm.Db.Crud.add_idea(collection_id, user_id)
      |> UUID.binary_to_string!()

    Storm.Db.Crud.add_pro(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("pro")

    Storm.Db.Crud.add_con(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("con")

    Storm.Db.Crud.add_comment(idea_id, user_id)
    |> UUID.binary_to_string!()
    |> Storm.Db.Crud.update_text("comment")

    %Storm.Collection{
      ideas: [
        %Storm.Idea{
          pros: [
            %Storm.Text{
              content: pro_content
            }
          ],
          cons: [
            %Storm.Text{
              content: con_content
            }
          ],
          comments: [
            %Storm.Text{
              content: comment_content
            }
          ]
        }
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert pro_content == "pro"
    assert con_content == "con"
    assert comment_content == "comment"
  end

  test "delete text" do
    {collection_id, user_id} = Storm.DbInit.add_test_collection()

    idea_id =
      Storm.Db.Crud.add_idea(collection_id, user_id)
      |> UUID.binary_to_string!()

    Storm.Db.Crud.add_pro(idea_id, user_id)
    Storm.Db.Crud.add_con(idea_id, user_id)
    Storm.Db.Crud.add_comment(idea_id, user_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{
          comments: [
            %Storm.Text{
              id: text_id
            }
          ]
        }
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    Storm.Db.Crud.delete_text(text_id)

    %Storm.Collection{
      ideas: [
        %Storm.Idea{
          comments: comments,
          cons: cons,
          content: nil,
          description: nil, 
          pros: pros
        }
      ]
    } = Storm.Db.Crud.get_collection(collection_id)

    assert 0 == length(comments)
    assert 1 == length(pros)
    assert 1 == length(cons)
  end
end

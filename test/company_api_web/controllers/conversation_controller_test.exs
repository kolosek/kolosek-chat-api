defmodule ConversationControllerTest do
  use CompanyApiWeb.ConnCase

  import CompanyApi.Factory

  setup do
    user_one = insert(:user)
    user_two = insert(:user)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)

    {:ok, user_one: user_one, user_two: user_two, new_conn: new_conn}
  end

  test "creates conversation", %{user_two: user_two, new_conn: new_conn} do
    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})

    assert response(res, 201)
  end

  test "creates another chat for user", %{user_two: user_two, new_conn: new_conn} do
    post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})

    user_three = insert(:user)

    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: user_three.id})

    assert response(res, 201)
  end

  test "tries to create existing conversation", %{user_two: user_two, new_conn: new_conn} do
    post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})

    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: user_two.id})
      |> json_response(200)

    refute res["id"] == nil
  end

  test "tries to create with invalid data", %{new_conn: new_conn} do
    res =
      post(new_conn, conversation_path(new_conn, :create), %{recipient: 0})
      |> json_response(422)

    assert res["error"] != nil
  end

  test "gets active conversations", %{user_one: user_one, user_two: user_two, new_conn: new_conn} do
    conversation = insert(:conversation, sender: user_one, recipient: user_two)

    res =
      get(new_conn, conversation_path(new_conn, :index))
      |> json_response(200)

    expected = [%{"id" => conversation.id, "status" => nil}]

    assert res == expected
  end

  test "gets non-existing convs", %{new_conn: new_conn} do
    res =
      get(new_conn, conversation_path(new_conn, :index))
      |> json_response(200)

    assert res == []
  end
end

defmodule CompanyApiWeb.MessageControllerTest do
  use CompanyApiWeb.ConnCase

  import CompanyApi.Factory

  setup do
    user_one = insert(:user)
    user_two = insert(:user)

    conversation = insert(:conversation, sender: user_one, recipient: user_two)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user_one)

    {:ok, user: user_one, new_conn: new_conn, conv: conversation}
  end

  test "gets all messages for conversation", %{user: user, new_conn: new_conn, conv: conv} do
    m_one   = insert(:message, sender: user, conversation: conv)
    m_two   = insert(:message, sender: user, conversation: conv)
    m_three = insert(:message, sender: user, conversation: conv)

    res =
      get(new_conn, message_path(new_conn, :index), %{conv: conv.id})
      |> json_response(200)

    expected = [
      %{"sender" => m_one.sender_id, "conversation" => m_one.conversation_id,
        "content" => m_one.content, "date" => m_one.date
      },
      %{"sender" => m_two.sender_id, "conversation" => m_two.conversation_id,
        "content" => m_two.content, "date" => m_two.date
      },
      %{"sender" => m_three.sender_id, "conversation" => m_three.conversation_id,
        "content" => m_three.content, "date" => m_three.date
      }
    ]

    assert res == expected
  end

  test "tries to get messeges when there are none", %{new_conn: new_conn} do
    res =
      get(new_conn, message_path(new_conn, :index), %{conv: 0})
      |> json_response(200)

    assert res == []
  end
end

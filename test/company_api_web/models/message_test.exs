defmodule CompanyApiWeb.MessagesTest do
  use CompanyApi.DataCase, async: true

  alias CompanyApiWeb.Message

  import CompanyApi.Factory
  
  setup do
    user_one = insert(:user)
    user_two = insert(:user)
    conversation = insert(:conversation, sender: user_one, recipient: user_two)

    {:ok, user: user_one, conv: conversation}
  end

  test "message with valid data", %{user: user_one, conv: conversation} do
    message = Message.changeset(%Message{}, %{sender_id: user_one.id,
                                              conversation_id: conversation.id,
                                              content: "This is the message.",
                                              date: DateTime.to_naive(DateTime.utc_now)
                                             })
    assert message.valid?
  end

  test "message with missing data" do
    message = Message.changeset(%Message{}, %{})

    refute message.valid?
  end

  test "message creation", %{user: user, conv: conv} do
    message = Message.create_message(user.id, conv.id, "Haha message")

    inserted_message = Repo.get!(Message, message.id)

    assert message == inserted_message
  end

  test "message creation with invalid data" do
    message = Message.create_message(0, 0, "Wrong message")

    assert message == nil
  end
end


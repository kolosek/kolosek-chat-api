defmodule CompanyApiWeb.ConversationTest do
  use CompanyApi.DataCase

  alias CompanyApiWeb.Conversation
  alias CompanyApi.Repo

  @valid_attributes %{sender_id: 1, recipient_id: 2, status: "Unread"}

  test "conversation with valid attributes" do
    conversation = Conversation.changeset(%Conversation{}, @valid_attributes)

    assert conversation.valid?
  end

  test "conversation with invalid attributes" do
    conversation = Conversation.changeset(%Conversation{}, %{})

    refute conversation.valid?
  end

  test "conversation with uniqueness not satisfied" do
    conversation = Conversation.changeset(%Conversation{}, @valid_attributes)
    Repo.insert(conversation)

    {_, result} = Repo.insert(conversation)

    refute result.valid?
  end
end

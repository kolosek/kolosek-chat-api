defmodule CompanyApiWeb.ConversationController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.Conversation

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    conversations =
      Conversation.get_conversations(user.id)
      |> Repo.all

    conn
    |> put_status(:ok)
    |> render("index.json", %{conversations: conversations})
  end

  def create(conn, %{"recipient" => id}) do
    user = Guardian.Plug.current_resource(conn)
    conversation =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: user.id, recipient_id: id})

    case Repo.insert(conversation) do
      {:ok, conversation} ->
        conn
        |> put_status(:created)
        |> render("conversation.json", %{conv: conversation})
      {:error, _error_conv} ->
        case Repo.get_by(Conversation, %{sender_id: user.id, recipient_id: id}) do
          nil ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", %{message: "Can't create"})
          existing_conv ->
            conn
            |> put_status(:ok)
            |> render("conversation.json", %{conv: existing_conv})
        end
    end
  end
end

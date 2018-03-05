defmodule CompanyApiWeb.MessageController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.Message

  def index(conn, %{"conv" => conv_id}) do
    messages =
      Message.get_message_query(conv_id)
      |> Repo.all

    conn
    |> put_status(:ok)
    |> render("index.json", messages: messages)
  end
end

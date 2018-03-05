defmodule CompanyApiWeb.MessageView do
  use CompanyApiWeb, :view

  def render("index.json", %{messages: messages}) do
    render_many(messages, CompanyApiWeb.MessageView, "message.json")
  end

  def render("message.json", %{message: message}) do
    %{sender:       message.sender_id,
      conversation: message.conversation_id,
      content:      message.content,
      date:         message.date
    }
  end
end

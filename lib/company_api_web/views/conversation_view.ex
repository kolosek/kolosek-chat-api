defmodule CompanyApiWeb.ConversationView do
  use CompanyApiWeb, :view

  def render("index.json", %{conversations: convs}) do
    render_many convs, CompanyApiWeb.ConversationView, "conversation.json", as: :conv
  end

  def render("create.json", %{conv: conv}) do
    render_one(conv, CompanyApiWeb.ConversationView, "conversation.json")
  end

  def render("error.json", %{message: content}) do
    %{error: content}
  end

  def render("conversation.json", %{conv: conv}) do
    %{id: conv.id, status: nil}
  end
end

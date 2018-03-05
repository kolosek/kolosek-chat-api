defmodule CompanyApiWeb.Email do
  import Bamboo.Email

  def create_mail(password, email) do
    new_email()
    |> to(email)
    |> from("company@gmail.com")
    |> subject("Generated password")
    |> html_body("<h1>Welcome to Chat</h1>")
    |> text_body("Welcome. This is your generated password #{password}. You can change it anytime.")
  end
end

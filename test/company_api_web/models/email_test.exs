defmodule CompanyApiWeb.EmailTest do
  use CompanyApi.DataCase, async:  true

  alias CompanyApiWeb.Email

  @email "johndoe@gmail.com"
  @password "johndoe"

  test "creates new email" do
    email = Email.create_mail("johndoe", "johndoe@gmail.com")

    assert email.to == @email
    assert email.text_body =~ @password
  end
end

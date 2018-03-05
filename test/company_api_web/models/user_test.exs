defmodule CompanyApiWeb.UserTest do
  use CompanyApi.DataCase, async: true

  alias CompanyApiWeb.User

  @valid_attributes %{name: "John",
                      subname: "Doe",
                      email: "doe@gmail.com",
                      job: "web developer"
                     }

  @missing_attributes %{}

  @wrong_mail %{name: "John",
                subname: "Doe",
                email: "mail.mail.com",
                job: "web developer"
               }

  test "user with valid attributes" do
    user = User.reg_changeset(%User{}, @valid_attributes)

    assert user.valid?
  end

  test "user with missing all attributes" do
    user = User.reg_changeset(%User{}, @missing_attributes)

    refute user.valid?
  end

  test "user with missing name and subname" do
    user = User.reg_changeset(%User{}, %{email: "cool@gmail.com", job: "engineer"})

    refute user.valid?
  end
  test "user with invalid email" do
    user = User.reg_changeset(%User{}, @wrong_mail)

    refute user.valid?
  end
end

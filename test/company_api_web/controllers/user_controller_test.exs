defmodule CompanyApiWeb.UserControllerTest do
  use CompanyApiWeb.ConnCase
  use Bamboo.Test, shared: :true

  import CompanyApi.Factory

  @valid_data %{name:    "Jim",
                subname: "Doe",
                email:   "doe@gmail.com",
                job:     "CEO"
               }

  @invalid_data %{}

  @password "Random pass"

  setup do
    user = insert(:user)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    %{conn: conn, user: user}
  end

  test "tries to get all users", %{conn: conn} do
    get(conn, user_path(conn, :index)) |> json_response(200)
  end

  describe "tries to create and render" do
    test "user with valid data", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: @valid_data)
        |> json_response(201)

      assert Repo.get_by(User, @valid_data)
      assert_delivered_email Email.create_mail(response["password"], response["email"])
    end

    test "user with invalid data", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: @invalid_data)
        |> json_response(422)

      assert response["errors"] != %{}
    end

    test "when user has no email", %{conn: conn} do
      response =
        post(conn, user_path(conn, :create), user: Map.delete(@valid_data, :email))
        |> json_response(422)

      assert response["errors"] != %{}
      refute Repo.get_by(User, @valid_data)
    end
 end

  describe "tries to change user password" do
    test "with valid data", %{conn: conn, user: user} do
      response =
        put(conn, user_path(conn, :change_password, user.id), password: @password)
        |> json_response(200)

      assert response == @password
      assert Repo.get_by(User, %{id: user.id}).password == @password
    end

    test "with wrong user id", %{conn: conn} do
      response =
        put(conn, user_path(conn, :change_password, 0), password: @password)
        |> json_response(422)

      assert response["errors"] != %{}
      refute Repo.get_by(User, %{id: 0})
    end
  end

  test "uploads user profil image", %{conn: conn, user: user} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
    profile_image = %Plug.Upload{path: "test/company_api_web/fixtures/image.jpg",
                                 filename: "image.jpg"
                                }

    res =
      post(new_conn, user_path(new_conn, :upload), image: profile_image)
      |> json_response(200)

    assert res["image"]["file_name"] == profile_image.filename
  end

  test "tries to upload wrong data", %{conn: conn, user: user} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)

    upload = %Plug.Upload{path: "", filename: ""}
    res =
      post(new_conn, user_path(new_conn, :upload), image: upload)
      |> json_response(422)

    assert res["errors"] != %{}
  end
end

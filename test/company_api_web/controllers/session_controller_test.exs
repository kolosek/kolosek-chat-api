defmodule CompanyApiWeb.SessionControllerTest do
  use CompanyApiWeb.ConnCase

  import CompanyApi.Factory

  @invalid_credentials %{email: "jane@gmail.com", password: "jane"}

  setup do
    user = insert(:user)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  test "login as user", %{conn: conn, user: user} do
    user_credentials = %{email: user.email, password: user.password}
    response =
      post(conn, session_path(conn, :create), creds: user_credentials)
      |> json_response(200)

    expected = %{
      "id"        => user.id,
      "name"      => user.name,
      "subname"   => user.subname,
      "password"  => user.password,
      "email"     => user.email,
      "job"       => user.job
    }

    assert response["data"]["user"]   == expected
    refute response["data"]["token"]  == nil
    refute response["data"]["expire"] == nil
  end

  test "login with invalid credentials", %{conn: conn} do
    response =
      post(conn, session_path(conn, :create), creds: @invalid_credentials)
      |> json_response(401)

    assert response["data"] == "No user with these credentials"
  end

  test "logout logged in user", %{conn: conn, user: user} do
    new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)

    logout_response =
      delete(new_conn, session_path(new_conn, :delete))
      |> json_response(200)

    assert logout_response["data"] == "Success logout"
  end

  test "tries to logout unlogged user", %{conn: conn} do
    logout_response =
      delete(conn, session_path(conn, :delete))
      |> json_response(401)

    assert logout_response["message"] == "unauthenticated"
  end
end

defmodule CompanyApiWeb.SessionController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.User

  def create(conn, %{"creds" => params}) do
    new_params = Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
    case User.check_registration(new_params) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
        token    = Guardian.Plug.current_token(new_conn)
        claims   = Guardian.Plug.current_claims(new_conn)
        expire   = Map.get(claims, "exp")

        new_conn
        |> put_resp_header("authorization", "Bearer #{token}")
        |> put_status(:ok)
        |> render("login.json", user: user, token: token, exp: expire)
      {:error, reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: reason)
    end
  end

  def delete(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    case Guardian.revoke(CompanyApi.Guardian, token) do
      {:ok, _} ->
        conn
        |> put_status(:ok)
        |> render("logout.json")
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", message: "Token does not exist")
    end
  end
end

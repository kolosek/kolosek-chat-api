defmodule CompanyApi.GuardianErrorHandler do
  def auth_error(conn, {_type, reason}, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, Poison.encode!(%{message: to_string(reason)}))
  end
end

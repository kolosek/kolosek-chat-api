defmodule CompanyApiWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", CompanyApiWeb.ChatRoom

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case Guardian.Phoenix.Socket.authenticate(socket, CompanyApi.Guardian, token) do
      {:ok, socket} ->
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    "user_socket:#{user.id}"
  end
end

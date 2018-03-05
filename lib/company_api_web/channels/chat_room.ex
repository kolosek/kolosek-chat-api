defmodule CompanyApiWeb.ChatRoom do
  use CompanyApiWeb, :channel

  alias CompanyApi.{ChannelSessions, ChannelUsers}
  alias CompanyApiWeb.Message

  def join("room:chat", _payload, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    send(self(), {:after_join, user})

    {:ok, socket}
  end

  def handle_in("send_msg", %{"user" => id, "conv" => conv_id, "message" => content}, socket) do
    case ChannelSessions.get_socket id do
      nil ->
        {:error, socket}
      socketz ->
        user = Guardian.Phoenix.Socket.current_resource(socket)
        case Message.create_message(user.id, conv_id, content) do
          nil ->
            {:noreply, socket}
          message ->
            push socketz, "receive_msg", %{message: message}
            {:noreply, socket}
        end
    end
  end

  def handle_info({:after_join, user}, socket) do
    ChannelSessions.save_socket(user.id, socket)
    ChannelUsers.user_joined(user, "room:chat")

    {:noreply, socket}
  end

  def terminate(_msg, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    ChannelSessions.delete_socket user.id
    ChannelUsers.user_leave(user, "room:chat")
  end
end

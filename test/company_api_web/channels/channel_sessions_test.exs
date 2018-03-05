defmodule CompanyApiWeb.ChannelSessionsTest do
  use CompanyApi.DataCase, async: true

  alias CompanyApi.ChannelSessions

  @user_id 1

  setup do
    ChannelSessions.clear()

    socket = %Phoenix.Socket{}
    socket_map = ChannelSessions.save_socket(@user_id, socket)

    %{socket_map: socket_map}
  end

  test "gets socket by user id" do
    socket = ChannelSessions.get_socket @user_id

    refute socket == nil
  end

  test "gets socket by non-existing id" do
    socket = ChannelSessions.get_socket(2)

    assert socket == nil
  end

  test "stores new socket" do
    socket_map = ChannelSessions.save_socket(2, %Phoenix.Socket{})

    assert length(Map.values(socket_map)) == 2
  end

  test "deletes socket" do
    socket_map = ChannelSessions.delete_socket @user_id

    assert socket_map == %{}
  end

  test "tries to delete socket with non-existing id", %{socket_map: socket_map} do
    new_socket_map = ChannelSessions.delete_socket(2)

    assert new_socket_map == socket_map
  end
end

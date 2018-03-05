defmodule CompanyApiWeb.ChannelUsersTest do
  use CompanyApi.DataCase

  alias CompanyApiWeb.User
  alias CompanyApi.ChannelUsers

  @channel_one 1
  @channel_two 2

  setup do
    ChannelUsers.clear()
    user_one_data = %{name:    "John",
                      subname: "Doe",
                      email:   "doebro@gmail.com",
                      job:     "engineer"
                     }

    user_two_data = %{name:    "Jane",
                      subname: "Doe",
                      email:   "janefromtheblock@gmail.com",
                      job:     "civil engineer"
                     }

    {_, user_one} = Repo.insert(User.reg_changeset(%User{}, user_one_data))
    {_, user_two} = Repo.insert(User.reg_changeset(%User{}, user_two_data))
    ChannelUsers.user_joined(user_one, @channel_one)

    %{user_one: user_one, user_two: user_two}
  end

  test "user joins lobby", %{user_one: user_one, user_two: user_two} do
    users = ChannelUsers.user_joined(user_two, @channel_one)

    assert Enum.at(users[@channel_one], 0) == user_two
    assert Enum.at(users[@channel_one], 1) == user_one
  end

  test "user joins lobby twice", %{user_one: user_one} do
    users = ChannelUsers.user_joined(user_one, @channel_one)

    assert Enum.at(users[@channel_one], 0) == user_one
    assert length(users[@channel_one]) == 1
  end

  test "user joins different lobby", %{user_two: user_two} do
    users = ChannelUsers.user_joined(user_two, @channel_two)

    assert Enum.at(users[@channel_two], 0) == user_two
    assert length(users[@channel_two]) == 1
  end

  test "user leaves lobby", %{user_one: user_one} do
    users = ChannelUsers.user_leave(user_one, @channel_one)

    assert users[@channel_one] == []
  end

  test "non-existing user leaves lobby", %{user_two: user_two} do
    users = ChannelUsers.user_leave(user_two, @channel_one)

    refute users[@channel_one] == []
  end

  test "gets all online users", %{user_one: user_one} do
    users = ChannelUsers.get_online_users @channel_one

    assert length(users) == 1
    assert Enum.at(users, 0) == user_one
  end
end

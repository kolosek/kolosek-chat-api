defmodule CompanyApi.ChannelUsers do
  use GenServer

  #Client side

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def get_online_users(channel) do
    GenServer.call(__MODULE__, {:get_online_users, channel})
  end

  def user_joined(user, channel) do
    GenServer.call(__MODULE__, {:user_joined, user, channel})
  end

  def user_leave(user, channel) do
    GenServer.call(__MODULE__, {:user_left, user, channel})
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  #Server callbacks

  def handle_call({:get_online_users, channel}, _from, online_users) do
    {:reply, Map.get(online_users, channel), online_users}
  end

  def handle_call({:user_joined, user, channel}, _from, online_users) do
    new_state =
      case Map.get(online_users, channel) do
        nil ->
          Map.put(online_users, channel, [user])
        users ->
          Map.put(online_users, channel,
                  Enum.uniq_by([user | users], fn user -> user.email end))
      end

    {:reply, new_state, new_state}
  end

  def handle_call({:user_left, user, channel}, _from, online_users) do
    new_users =
      online_users
      |> Map.get(channel)
      |> Enum.reject(&(&1.email == user.email))

    new_state = Map.update!(online_users, channel, fn(_) -> new_users end)

    {:reply, new_state, new_state}
  end

  def handle_call(:clear, _from, _online_users) do
    {:reply, %{}, %{}}
  end
end

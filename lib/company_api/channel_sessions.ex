defmodule CompanyApi.ChannelSessions do
  use GenServer

  #Client side

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def save_socket(user_id, socket) do
    GenServer.call(__MODULE__, {:save_socket, user_id, socket})
  end

  def delete_socket(user_id) do
    GenServer.call(__MODULE__, {:delete_socket, user_id})
  end

  def get_socket(user_id) do
    GenServer.call(__MODULE__, {:get_socket, user_id})
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  #Server callbacks

  def handle_call({:save_socket, user_id, socket}, _from, socket_map) do
    case Map.has_key?(socket_map, user_id) do
      true ->
        {:reply, socket_map, socket_map}
      false ->
        new_state = Map.put(socket_map, user_id, socket)
        {:reply, new_state, new_state}
    end
  end

  def handle_call({:delete_socket, user_id}, _from, socket_map) do
    new_state = Map.delete(socket_map, user_id)

    {:reply, new_state, new_state}
  end

  def handle_call({:get_socket, user_id}, _from, socket_map) do
    socket = Map.get(socket_map, user_id)

    {:reply, socket, socket_map}
  end

  def handle_call(:clear, _from, state) do
    {:reply, %{}, %{}}
  end
end

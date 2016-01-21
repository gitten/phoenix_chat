defmodule PhoenixChat.RoomServer do
  use GenServer

  def start_single do
    case GenServer.start(PhoenixChat.RoomServer, nil, name: :room_server) do
      {:ok, room_server} ->
        room_server
      {:error, {:already_started, room_server}} ->
        room_server
    end
  end
  
  def start do
    GenServer.start(PhoenixChat.RoomServer, nil, name: :room_server)
  end

  def add_entry(room_server, new_entry) do
    GenServer.cast(room_server, {:add_entry, new_entry})
  end

  def update_entry(room_server, new_entry) do
    GenServer.cast(room_server, {:add_entry, new_entry})
  end

  def entries(room_server, user_id) do
    GenServer.call(room_server, {:entries, user_id})
  end

  def entries(room_server) do
    GenServer.call(room_server, {:entries})
  end
  
  def size(room_server) do
    GenServer.call(room_server, {:size})
  end

  def init(_) do
    :timer.send_interval(2000, :heartbeat)
    {:ok, PhoenixChat.RoomList.new}
  end

  def handle_cast({:add_entry, new_entry}, room_list) do
    new_state = PhoenixChat.RoomList.add_entry(room_list, new_entry)
    {:noreply, new_state}
  end

  def handle_call({:entries, user_id}, _, room_list) do
    {
      :reply,
      PhoenixChat.RoomList.entries(room_list, user_id),
      room_list
    }
  end

  def handle_call({:entries}, _, room_list) do
    {
      :reply,
      PhoenixChat.RoomList.entries(room_list),
      room_list
    }
  end

  def handle_call({:size}, _, room_list) do
    {
      :reply,
      PhoenixChat.RoomList.size(room_list),
      room_list
    }
  end
  
  def handle_info(:heartbeat, state) do
    PhoenixChat.Endpoint.broadcast! "rooms:lobby", "heartbeat", %{:time => :erlang.system_time(), :user_list => "user_list"}
    {:noreply, state}
  end
  
  # Needed for testing purposes
  def handle_info(:stop, room_list), do: {:stop, :normal, room_list}
  
  def handle_info(_, state) do
    {:noreply, state}
  end
end
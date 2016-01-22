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
    GenServer.call(room_server, {:add_entry, new_entry})
  end
  
  def entries(room_server, param) do
    GenServer.call(room_server, {:entries, param})
  end

  def size(room_server, param) do
    GenServer.call(room_server, {:size, param})
  end
    
  def update_heartbeat(room_server, user_id) do
    GenServer.cast(room_server, {:update_heartbeat, user_id})
  end

  def init(_) do
    :timer.send_interval(2000, :heartbeat_loop)
    {:ok, PhoenixChat.RoomList.new}
  end

  def handle_cast({:update_heartbeat, user_id}, room_list) do
    new_state = PhoenixChat.RoomList.update_heartbeat(room_list, user_id)
    #IO.inspect [:new_heartbeat, user_id, new_state]
    {:noreply, new_state}
  end

  def handle_call({:add_entry, new_entry}, _, room_list) do
    {new_state, updated_new_entry} = PhoenixChat.RoomList.add_entry(room_list, new_entry)
    {
      :reply,
      updated_new_entry,
      new_state
    }
  end

  def handle_call({:entries, param}, _, room_list) do
    IO.inspect [:entries_Test, PhoenixChat.RoomList.entries(room_list, param)]
    {
      :reply,
      PhoenixChat.RoomList.entries(room_list, param),
      room_list
    }
  end

  def handle_call({:size, presence}, _, room_list) do
    #IO.inspect [:afaf, PhoenixChat.RoomList.size(room_list, presence) ]
    {
      :reply,
      PhoenixChat.RoomList.size(room_list, presence),
      room_list
    }
  end
  
  def handle_info(:heartbeat_loop, room_list) do
    new_state = PhoenixChat.RoomList.update_entries_presence(room_list)
    PhoenixChat.Endpoint.broadcast! "rooms:lobby", "heartbeat", %{:time => :erlang.system_time(), :user_list => "user_list"}
    {:noreply, new_state}
  end
  
  # Needed for testing purposes
  def handle_info(:stop, room_list), do: {:stop, :normal, room_list}
  
  def handle_info(_, state) do
    {:noreply, state}
  end
end
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

  #def update_entry(room_server, {:user_id, user_id, new_entry}) do
  #  GenServer.cast(room_server, {:update_entry, {:user_id, user_id, new_entry}})
  #end

  def entries(room_server, user_id) do
    GenServer.call(room_server, {:entries, user_id})
  end

  def add_entry(room_server, new_entry) do
    GenServer.call(room_server, {:add_entry, new_entry})
  end
  
  def entries(room_server) do
    GenServer.call(room_server, {:entries})
  end
  
  def size(room_server) do
    GenServer.call(room_server, {:size})
  end

  def update_heartbeat(room_server, user_id) do
    GenServer.cast(room_server, {:update_heartbeat, user_id})
  end

  def init(_) do
    :timer.send_interval(2000, :heartbeat_loop)
    {:ok, PhoenixChat.RoomList.new}
  end

  #def handle_cast({:update_entry, {:user_id, user_id, new_entry}}, room_list) do
  #  new_state = PhoenixChat.RoomList.update_entry()
  #  {:noreply, new_state}

  #end
  def handle_cast({:update_heartbeat, user_id}, room_list) do
    new_state = PhoenixChat.RoomList.update_heartbeat(room_list, user_id)
    IO.inspect [:newbeat,  new_state, :user_id, user_id, :room_list,  room_list]
    #{:noreply, new_state}
    {:noreply, new_state}
  end


  def handle_call({:add_entry, new_entry}, _, room_list) do
    #IO.inspect %{:rlll => room_list}
    {new_state, updated_new_entry} = PhoenixChat.RoomList.add_entry(room_list, new_entry)

    #new_state = Todo.List.add_entry(todo_list, new_entry)
    #Todo.Database.store(name, new_state)
    #IO.puts "new state:"
    #IO.inspect %{:n => new_state}
    {
      :reply,
      updated_new_entry,
      new_state
    }
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
  
  def handle_info(:heartbeat_loop, room_list) do
    
  
    #room_server = PhoenixChat.RoomServer.start_single
    #user = PhoenixChat.RoomServer.add_entry(room_server,
    #  %{user_id: {user_id},
    #    name: user_id,
    #    heartbeat: user_id,
    #    presence: "present",
    #    pid: self})
    #x = PhoenixChat.RoomServer.size(room_server)
    #state = PhoenixChat.RoomServer.entries(room_server)
    #IO.inspect %{:heartbeat_state => room_list}
    #id = user.user_id
    
    #new_presence = "missing"  # "missing"

    #   IO.inspect %{:heartbeat_state => state}
    new_state = PhoenixChat.RoomList.update_entries_presence(room_list)
    #IO.inspect %{:map_to_list_heartbeat_handle_info_state => Map.to_list(state)}
    #IO.inspect %{:map_to_list_heartbeat_handle_info_state => state}
    #PhoenixChat.RoomList.update_entry(state, id, &Map.put(id, :presence, new_presence))

#    new_state = state
    #token = Phoenix.Token.sign(conn, "user", id)
    #assign(conn, :user_token, token)
  
  
    PhoenixChat.Endpoint.broadcast! "rooms:lobby", "heartbeat", %{:time => :erlang.system_time(), :user_list => "user_list"}
    #IO.inspect %{:nesta => new_state}
    {:noreply, new_state}
  end
  
  # Needed for testing purposes
  def handle_info(:stop, room_list), do: {:stop, :normal, room_list}
  
  def handle_info(_, state) do
    {:noreply, state}
  end
end
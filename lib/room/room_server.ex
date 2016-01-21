defmodule PhoenixChat.RoomServer do
  use GenServer

  def start do
    GenServer.start(PhoenixChat.RoomServer, nil)
  end

  def add_entry(room_server, new_entry) do
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
  
  
  # Needed for testing purposes
  def handle_info(:stop, room_list), do: {:stop, :normal, room_list}
  def handle_info(_, state), do: {:noreply, state}
end
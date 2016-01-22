defmodule PhoenixChat.RoomList do
  defstruct auto_id: 1, entries: Map.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %PhoenixChat.RoomList{},
      &add_entry(&2, &1)
    )
  end
  
  def size(room_list, nil) do
    Map.size(room_list.entries)
  end
  
  def size(room_list, :present) do
    room_list.entries
    |> Stream.filter(fn({_, entry}) ->
         entry.presence == "present"
       end)
    |> Enum.to_list
    |> Enum.into(%{})
    |> Map.size
  end

  def add_entry(
    %PhoenixChat.RoomList{entries: entries, auto_id: auto_id} = room_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, entry[:user_id], entry)
    {
      %PhoenixChat.RoomList{room_list | 
        entries: new_entries,
        auto_id: auto_id + 1
      },
      entry
    }
  end

  def entries(%PhoenixChat.RoomList{entries: entries}, :user_id, user_id) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.user_id == user_id
       end)
    |> Enum.map(fn({_, entry}) ->
         entry
       end)
  end
  
  def entries(%PhoenixChat.RoomList{entries: entries}, nil) do
    entries
  end
  
  def entries(%PhoenixChat.RoomList{entries: entries}, :present) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.presence == "present"
       end)
    |> Enum.to_list
    |> Enum.into(%{})
  end

  def entries_to_list(%PhoenixChat.RoomList{entries: entries}) do
    entries
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
    |> Enum.to_list
end

  def update_entries_presence(%PhoenixChat.RoomList{entries: entries, auto_id: auto_id}) do
    new_entries = update_presence_all(entries)
    %PhoenixChat.RoomList{entries: new_entries,
        auto_id: auto_id
    }
  end

  defp update_presence_all(entries) do
    entries
    |> Enum.map(fn {k, v} ->
        {k, update_presence(v)}
      end)
    |> Enum.into(%{})
  end

  defp update_presence(entry) do
    now = :erlang.system_time()
    heartbeat = entry.heartbeat
    diff = now - heartbeat
    if entry[:presence] != "closed" do
      if diff > 5999133052 do
        entry = Map.put(entry, :presence, "missing")
      else
        entry = Map.put(entry, :presence, "present")
      end
    end
    entry
  end

  def update_heartbeat(room_list, entry_id) do
    update_entry(room_list, entry_id, fn(old_entry) -> Map.put(old_entry, :heartbeat, :erlang.system_time()) end)
  end

  def close_user(room_list, entry_id) do
    update_entry(room_list, entry_id, fn(old_entry) -> Map.put(old_entry, :presence, "closed") end)
  end

  def update_entry(
    %PhoenixChat.RoomList{entries: entries} = room_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil ->
        room_list
      old_entry ->
        old_entry_id = old_entry.user_id
        new_entry = %{user_id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.user_id, new_entry)
        %PhoenixChat.RoomList{room_list | entries: new_entries}
    end
  end

  def delete_entry(
    %PhoenixChat.RoomList{entries: entries} = room_list,
    entry_id
  ) do
    %PhoenixChat.RoomList{room_list | entries: Map.delete(entries, entry_id)}
  end
end
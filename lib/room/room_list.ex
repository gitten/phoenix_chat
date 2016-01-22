defmodule PhoenixChat.RoomList do
  defstruct auto_id: 1, entries: Map.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %PhoenixChat.RoomList{},
      &add_entry(&2, &1)
    )
  end

  def size(room_list) do
#    IO.inspect %{:pid => self, :as => room_list}
    Map.size(room_list.entries)
  end

  def add_entry(
    %PhoenixChat.RoomList{entries: entries, auto_id: auto_id} = room_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, entry[:user_id], entry)
    #IO.inspect new_entries
    #IO.inspect %{:pid => self, :as => room_list}
    {
      %PhoenixChat.RoomList{room_list |
        entries: new_entries,
        auto_id: auto_id + 1
      },
      entry
    }
  end

  def entries(%PhoenixChat.RoomList{entries: entries}, user_id) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.user_id == user_id
       end)
    |> Enum.map(fn({_, entry}) ->
         entry
       end)
  end
  
  def entries(%PhoenixChat.RoomList{entries: entries}) do
    entries
    #|> Stream.filter(fn({_, entry}) ->
    #     entry.user_id == user_id
    #   end)

    #|> Enum.map(fn({_, entry}) ->
    #     entry
    #   end)
  end
  
  def update_entries_presence(%PhoenixChat.RoomList{entries: entries, auto_id: auto_id}) do
    #|> Stream.filter(fn({_, entry}) ->
    #     entry.user_id == user_id
    #   end)
    #IO.inspect %{:before => entries}
    new_entries = update_presence_all(entries)
    #IO.inspect %{:after => new_entries}
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
        #  %{user_id: {user_id},
        #name: user_id,
        #heartbeat: user_id,
        #presence: "present",
        #pid: self})
    if entry.heartbeat + 666666 < :erlang.system_time() do
      entry = Map.put(entry, :presence, "missing")
      #IO.inspect %{:missing => entry}
    else
      entry = Map.put(entry, :presence, "present")
      #IO.inspect %{:present => entry}
    end
    entry
  end
  
  #def update_heartbeat(%PhoenixChat.RoomList{entries: entries, auto_id: auto_id}, user_id) do
    #entries
    #|> Stream.filter(fn({_, entry}) ->
   #      entry.user_id == user_id
   #    end)
   # |> Enum.map(fn({_, entry}) ->
   #      #update_heartbeat_entry(entry)
   #     entry
  #     end)
 #end
 
  def update_heartbeat(
    %PhoenixChat.RoomList{entries: entries} = room_list,
    user_id
  ) do
    case entries[user_id] do
      nil ->
        IO.inspect "NIL!!!"
        #IO.inspect entries
        room_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = Map.put(old_entry, :heartbeat, :erlang.system_time())
        #new_entry = %{} = updater_fun.(old_entry)
        #new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %PhoenixChat.RoomList{room_list | entries: new_entries}
    end
  end

  #defp update_heartbeat_entry(entry) do
  #  Map.put(entry, :heartbeat, :erlang.system_time())
  #end
  
  def update_entry(room_list, %{} = new_entry) do
    update_entry(room_list, new_entry.id, fn(_) -> new_entry end)
  end

  def update_entry(
    %PhoenixChat.RoomList{entries: entries} = room_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> room_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        #new_entry = %{} = updater_fun.(old_entry)
        #new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
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
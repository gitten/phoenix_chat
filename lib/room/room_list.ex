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
    Map.size(room_list.entries)
  end

  def add_entry(
    %PhoenixChat.RoomList{entries: entries, auto_id: auto_id} = room_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %PhoenixChat.RoomList{room_list |
      entries: new_entries,
      auto_id: auto_id + 1
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
        new_entry = updater_fun.(old_entry)
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
defmodule PhoenixChat.RoomChannel do
  use Phoenix.Channel
  
  def join("rooms:lobby", _message, socket) do
    room_server = PhoenixChat.RoomServer.start_single
    entries = PhoenixChat.RoomServer.entries(room_server, :present)
    users = PhoenixChat.RoomList.room_list(entries)
    {:ok, %{:user_id => socket.assigns.user_id, :user_list => users}, socket}
  end
  
  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
  
  def handle_in("heartbeat", %{"time" => time}, socket) do
    x = time
    room_server = PhoenixChat.RoomServer.start_single
    PhoenixChat.RoomServer.update_heartbeat(room_server, socket.assigns.user_id)
    {:noreply, socket}
  end
  
  def handle_in("close", _params, socket) do
    room_server = PhoenixChat.RoomServer.start_single
    PhoenixChat.RoomServer.close_user(room_server, socket.assigns.user_id)
    {:noreply, socket}
  end
  
  def handle_in("new_msg", %{"body" => body}, socket) do
    room_server = PhoenixChat.RoomServer.start_single
    user = PhoenixChat.RoomServer.entry(room_server, :user_id, socket.assigns.user_id)
    {:ok, now} =
      Timex.Date.local
      |> Timex.DateFormat.format("{ISO}")
    cond do
      Regex.match?(~r/^\d+$/, body) ->
        broadcast! socket, "seek", %{date: now, user_id: user.user_id, name: user.name, body: body, gender: user.gender}
      Regex.match?(~r/^\d+\.\d+$/, body) ->
        broadcast! socket, "speed", %{date: now, user_id: user.user_id, name: user.name, body: body, gender: user.gender }
      Regex.match?(~r/^p$/, body) ->
        broadcast! socket, "pause", %{date: now, user_id: user.user_id, name: user.name, body: body, gender: user.gender }
      Regex.match?(~r/^up$/, body) ->
        broadcast! socket, "play", %{date: now, user_id: user.user_id, name: user.name, body: body, gender: user.gender }
      true ->
        broadcast! socket, "new_msg", %{date: now, user_id: user.user_id, name: user.name, body: body, gender: user.gender }
    end
    {:noreply, socket}
  end
  
  def handle_in("user_info", %{"name" => name, "gender" => gender}, socket) do
    room_server = PhoenixChat.RoomServer.start_single
    user_id = socket.assigns.user_id
    user = PhoenixChat.RoomServer.entry(room_server, :user_id, socket.assigns.user_id)
    PhoenixChat.RoomServer.update_entry_field(room_server, user_id, :name, name)
    PhoenixChat.RoomServer.update_entry_field(room_server, user_id, :gender, gender)

    # new_state = PhoenixChat.RoomList.update_entries_presence(room_list)
    user_list = PhoenixChat.RoomList.entries(room_server)
    users = PhoenixChat.RoomList.entries_to_list(user_list)
    PhoenixChat.Endpoint.broadcast! "rooms:lobby", "heartbeat", %{:time => :erlang.system_time(), :user_list => users}
    {:noreply, socket}
  end

  intercept ["new_msg"]
  
  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
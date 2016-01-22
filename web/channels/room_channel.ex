defmodule PhoenixChat.RoomChannel do
  use Phoenix.Channel
  
  def join("rooms:lobby", _message, socket) do
    room_server = PhoenixChat.RoomServer.start_single
    entries = PhoenixChat.RoomServer.entries(room_server, :present)
    users = PhoenixChat.RoomList.room_list(entries)
    {:ok, %{:user_list => users}, socket}
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
    cond do
      Regex.match?(~r/^\d+$/, body) ->
        broadcast! socket, "seek", %{user_id: user.user_id, name: user.name, body: body }
      Regex.match?(~r/^\d+\.\d+$/, body) ->
        broadcast! socket, "speed", %{user_id: user.user_id, name: user.name, body: body }
      Regex.match?(~r/^p$/, body) ->
        broadcast! socket, "pause", %{user_id: user.user_id, name: user.name, body: body }
      Regex.match?(~r/^up$/, body) ->
        broadcast! socket, "play", %{user_id: user.user_id, name: user.name, body: body }
      true ->
        broadcast! socket, "new_msg", %{user_id: user.user_id, name: user.name, body: body }
    end
    {:noreply, socket}
  end

  intercept ["new_msg"]
  
  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
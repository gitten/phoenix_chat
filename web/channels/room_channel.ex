defmodule PhoenixChat.RoomChannel do
  use Phoenix.Channel
  
  def join("rooms:lobby", _message, socket) do
    #socket = assign(socket, :user, msg[:random.uniform(777)])
    {:ok, socket}
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
    IO.inspect [:closing_time, :erlang.system_time()]
    room_server = PhoenixChat.RoomServer.start_single
    #IO.inspect [:closing, socket.assigns.user_id]
    PhoenixChat.RoomServer.close_user(room_server, socket.assigns.user_id)
    {:noreply, socket}
  end
  
  def handle_in("new_msg", %{"body" => body}, socket) do
    cond do
      Regex.match?(~r/^\d+$/, body) ->
        broadcast! socket, "seek", %{body: body }
      Regex.match?(~r/^\d+\.\d+$/, body) ->
        broadcast! socket, "speed", %{body: body}
      Regex.match?(~r/^p$/, body) ->
        broadcast! socket, "pause", %{body: body}
      Regex.match?(~r/^up$/, body) ->
        broadcast! socket, "play", %{body: body}
      true ->
        broadcast! socket, "new_msg", %{body: body}
    end
    {:noreply, socket}
  end

  intercept ["new_msg"]
  
  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
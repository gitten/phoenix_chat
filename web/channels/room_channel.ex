defmodule PhoenixChat.RoomChannel do
  use Phoenix.Channel

  def join("rooms:lobby", _message, socket) do
    #socket = assign(socket, :user, msg[:random.uniform(777)])
    {:ok, socket}
  end
  
  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
  
  def handle_in("new_msg", %{"body" => body}, socket) do
    cond do
      Regex.match?(~r/^\d+$/, body) ->
        broadcast! socket, "seek", %{body: body }
      Regex.match?(~r/^\d+\.\d+$/, body) ->
        broadcast! socket, "speed", %{body: body}
      Regex.match?(~r/^p$/, body) ->
        IO.puts("pause" <> body)
        IO.inspect socket
        broadcast! socket, "pause", %{body: body}
      Regex.match?(~r/^up$/, body) ->
        broadcast! socket, "play", %{body: body}
      true ->
        broadcast! socket, "new_msg", %{body: body}
    end
  
    #if Regex.match?("%r/^[a-zA-Z0-9]+:[a-zA-Z0-9]+$/", body) do
    #if Regex.match?(~r/^[0-9]+$/, body) do
      #IO.puts("seek" <> body)
    #  broadcast! socket, "seek", %{body: body}
    #else if Regex.match?(~r/^[0-9]+.[0.9]+$/, body) do
      #IO.puts("speed" <> body)
     # broadcast! socket, "speed", %{body: body}
    #else if Regex.match?(~r/p/, body) do
      #IO.puts("pause" <> body)
      #broadcast! socket, "pause", %{body: body}
    #else
      #IO.puts(body)
    #  broadcast! socket, "new_msg", %{body: body}
    #end
    {:noreply, socket}
  end

  intercept ["new_msg"]
  
  def handle_out("new_msg", payload, socket) do
    #IO.puts "start"
    #IO.inspect payload
    #IO.inspect socket
    #    IO.puts "end"
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
defmodule PhoenixChat.RoomController do
  use PhoenixChat.Web, :controller
 
  def index(conn, _params) do
    :random.seed(:erlang.system_time())
    user_id = :random.uniform(99999999999)
    room_server = PhoenixChat.RoomServer.start_single
    user = PhoenixChat.RoomServer.add_entry(room_server,
      %{user_id: user_id,
        name: user_id,
        heartbeat: :erlang.system_time(),
        presence: "present",
        pid: to_string(:erlang.pid_to_list(self))})
    x = PhoenixChat.RoomServer.size(room_server, :present)
    y = PhoenixChat.RoomServer.entries(room_server, :present)
    id = user.user_id
    token = Phoenix.Token.sign(conn, "user", id)
    assign(conn, :user_token, token)
    render(conn, "index.html",
      room_data: y,
      room_size: x,
      user_id: id,
      channel_token: token)
  end  
end
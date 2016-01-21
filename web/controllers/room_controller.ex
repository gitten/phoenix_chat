defmodule PhoenixChat.RoomController do
  use PhoenixChat.Web, :controller

  #alias PhoenixChat.ContactForm

  #plug :scrub_params, "contact_form" when action in [:dakine]
 
  def index(conn, _params) do
    #IO.inspect conn

    room_server = PhoenixChat.RoomServer.start_single
    user_id = :erlang.system_time()
    user = PhoenixChat.RoomServer.add_entry(room_server,
      %{user_id: {user_id},
        name: :er,
        heartbeat: user_id})
    IO.inspect user
    #room_server = PhoenixChat.RoomServer.start_single
    :random.seed(:erlang.system_time())
    x = PhoenixChat.RoomServer.size(room_server)
    y = PhoenixChat.RoomServer.entries(room_server)
    render(conn, "index.html",
      room_data: y,
      room_size: x,
      user_id: user_id)
  end
  
end

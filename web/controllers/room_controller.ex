defmodule PhoenixChat.RoomController do
  use PhoenixChat.Web, :controller

  #alias PhoenixChat.ContactForm

  #plug :scrub_params, "contact_form" when action in [:dakine]
 
  def index(conn, _params) do
    case PhoenixChat.RoomServer.start do
      {:ok, room_server} ->
        serve(conn, _params, room_server)
      {:error, {:already_started, room_server}} ->
        serve(conn, _params, room_server)
    end
  end
 
  defp serve(conn, _params, room_server) do
    PhoenixChat.RoomServer.add_entry(room_server,
          %{user_id: {:random.uniform}, name: :random.uniform})
    #PhoenixChat.RoomServer.add_entry(room_server,
    #      %{user_id: {12}, name: "frafr"})
    x = PhoenixChat.RoomServer.size(room_server)
    y = PhoenixChat.RoomServer.entries(room_server)
    
    #IO.puts("hello")
    #IO.puts(x)
    IO.inspect y
    #IO.puts("goodbye")
    render(conn, "index.html",
      room_data: y,
      room_size: x)
  end
  
end

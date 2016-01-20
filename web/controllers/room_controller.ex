defmodule PhoenixChat.RoomController do
  use PhoenixChat.Web, :controller

  #alias PhoenixChat.ContactForm

  #plug :scrub_params, "contact_form" when action in [:dakine]
 
  def index(conn, _params) do
    render(conn, "index.html", dummy: nil)
  end
  
end

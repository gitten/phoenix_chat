defmodule PhoenixChat.Router do
  use PhoenixChat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  pipeline :room do
    plug :put_user_token
  end
  
  pipeline :room_layout do
    plug :put_layout, {PhoenixChat.RoomView, "room_layout.html"}
  end

  scope "/", PhoenixChat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
  
  scope "/", PhoenixChat do
    pipe_through [:browser, :put_user_token, :room_layout] # Use the default browser stack
    get "/room", RoomController, :index
  end
  
  # Other scopes may use custom stacks.
  # scope "/api", PhoenixChat do
  #   pipe_through :api
  # end
  defp put_user_token(conn, _) do
    conn = put_session(conn, :force_session_dummy_data, 'forced')
    IO.inspect conn
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

end

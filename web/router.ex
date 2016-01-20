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
  
  pipeline :room_layout do
    plug :put_layout, {PhoenixChat.RoomView, "room_layout.html"}
  end

  scope "/", PhoenixChat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
  
  scope "/", PhoenixChat do
    pipe_through [:browser, :room_layout] # Use the default browser stack
    get "/room", RoomController, :index
  end
  
  # Other scopes may use custom stacks.
  # scope "/api", PhoenixChat do
  #   pipe_through :api
  # end
end

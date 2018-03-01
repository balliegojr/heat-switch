defmodule SensorNodesWeb.Router do
  use SensorNodesWeb, :router

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

  scope "/", SensorNodesWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    resources "/nodes", NodeController, except: [:show]
    resources "/sensors", SensorController, except: [:new, :create]
    resources "/readings", ReadingController, except: [:new, :create]
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", SensorNodesWeb do
  #   pipe_through :api
  # end
end

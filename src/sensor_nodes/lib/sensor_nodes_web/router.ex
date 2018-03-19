defmodule SensorNodesWeb.Router do
  use SensorNodesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline, error_handler: SensorNodes.Auth.ErrorHandler, module: SensorNodes.Auth.Guardian
    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
  end
  
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_not_auth do 
    plug Guardian.Plug.EnsureNotAuthenticated

  end

  scope "/", SensorNodesWeb do
    pipe_through [:browser, :ensure_not_auth] # Use the default browser stack
    
    get "/signin", PageController, :login
    post "/signin", PageController, :signin
    get "/join", PageController, :join
    post "/signup", PageController, :signup
  end
 

  scope "/", SensorNodesWeb do
    pipe_through [:browser, :auth] # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
  end

  scope "/", SensorNodesWeb do
    pipe_through [:browser, :auth, :ensure_auth] # Use the default browser stack


    resources "/nodes", NodeController, except: [:show] do
      get "/sensors", SensorController, :filter_by_node
      get "/readings", ReadingController, :filter_by_node
    end
    resources "/sensors", SensorController, except: [:new, :create] do
      get "/readings", ReadingController, :filter_by_sensor
    end
    resources "/readings", ReadingController, except: [:new, :create]
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", SensorNodesWeb do
  #   pipe_through :api
  # end
end

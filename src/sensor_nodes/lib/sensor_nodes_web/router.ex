defmodule SensorNodesWeb.Router do
  use SensorNodesWeb, :router

  defp put_user_token(conn, _) do
    if current_user = Guardian.Plug.current_resource(conn) do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SensorNodesWeb.Locale
  end

  pipeline :auth do
    plug SensorNodes.Auth.Pipeline
    plug :put_user_token
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
  end

  scope "/", SensorNodesWeb do
    pipe_through [:browser, :auth, :ensure_auth] # Use the default browser stack
    
    get "/dashboard", PageController, :dashboard
    get "/signout", PageController, :signout
    get "/profile", UserController, :profile
    get "/editprofile", UserController, :edit_profile
    put "/editprofile", UserController, :update

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

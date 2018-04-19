defmodule SensorNodesWeb.PageController do
  use SensorNodesWeb, :controller
  alias SensorNodes.Accounts
  alias SensorNodes.Accounts.User
  alias SensorNodes.Auth.Guardian
  alias SensorNodes.Sensors

  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, _params) do
    render conn, "signin.html", 
      changeset: SensorNodes.Accounts.change_user(%User{}),
      action: page_path(conn, :signin)
  end

  def join(conn, _params) do
    render conn, "signup.html",
      changeset: SensorNodes.Accounts.change_user(%User{}),
      action: page_path(conn, :signup)
  end

  def signin(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Accounts.authenticate_user(email, password)
    |> signin_reply(conn)
  end


  def signup(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
         conn
          |> put_flash(:success, gettext("Welcome to TermoPower!"))
          |> Guardian.Plug.sign_in(user)
          |> redirect(to: node_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "signup.html", changeset: changeset, action: page_path(conn, :signup))
    end
  end
  
  def signout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: page_path(conn, :index))
  end
 

  defp signin_reply({:error, error}, conn) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: page_path(conn, :login))
  end

  defp signin_reply({:ok, user}, conn) do
    conn
    |> put_flash(:success, gettext("Welcome back!"))
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: node_path(conn, :index))
  end

  def dashboard(conn, _) do
    sensors = Sensors.list_sensors(Guardian.Plug.current_resource(conn).id)
    
    render(conn, "dashboard.html", sensors: sensors)
  end
end
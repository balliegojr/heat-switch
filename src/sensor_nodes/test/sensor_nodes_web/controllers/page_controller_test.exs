defmodule SensorNodesWeb.PageControllerTest do
  use SensorNodesWeb.ConnCase
  alias SensorNodes.Auth.Guardian
  
  import SensorNodesWeb.ControllersHelper

  describe "index" do
    test "show home page", %{conn: conn} do
      conn = get conn, page_path(conn, :index)
      assert html_response(conn, 200) =~ "Welcome to TermoPower online"
    end  
  end

  describe "login" do
    test "show signin page", %{conn: conn} do
      conn = get conn, page_path(conn, :login)
      assert html_response(conn, 200) =~ "Don&#39;t have an account?"
    end  
  end

  describe "join" do
    test "show signup page", %{conn: conn} do
      conn = get conn, page_path(conn, :join)
      assert html_response(conn, 200) =~ "Already have an account?"
    end  
  end

  describe "signin" do
     test "authenticate user and redirect to nodes page", %{conn: conn} do
      user = get_default_user()
      
      assert Guardian.Plug.authenticated?(conn) == false

      conn = post conn, page_path(conn, :signin), user: %{ email: user.email, password: user.password }
      assert redirected_to(conn) == node_path(conn, :index)
      assert Guardian.Plug.authenticated?(conn) == true
    end  
  end

  describe "signup" do
    test "register user and redirect to nodes page when data is valid", %{conn: conn} do

      conn = post conn, page_path(conn, :signup), user: %{ email: "register@email.com", password: "123", password_confirmation: "123" }
      assert redirected_to(conn) == node_path(conn, :index)
      assert Guardian.Plug.authenticated?(conn) == true
    end
    
    test "render errors when data is invalid", %{conn: conn} do

      conn = post conn, page_path(conn, :signup), user: %{ email: "register@email.com", password: "123", password_confirmation: "wrong confirmation" }
      assert html_response(conn, 200) =~ "Already have an account"
      assert Guardian.Plug.authenticated?(conn) == false
    end
  end

  describe "signout" do
    setup [:authenticate]

    test "signout the user and redirects to home page", %{conn: conn} do
      conn = get conn, page_path(conn, :signout)
      assert redirected_to(conn) == page_path(conn, :index)
      assert Guardian.Plug.authenticated?(conn) == false
    end
  end
end

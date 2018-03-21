defmodule SensorNodesWeb.UserControllerTest do
  use SensorNodesWeb.ConnCase

  import SensorNodesWeb.ControllersHelper
  alias SensorNodes.Accounts

  @update_attrs %{email: "another@email.com", password: "123", password_confirmation: "123" }
  @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

  describe "user profile" do
    setup [:authenticate]
    
    test "shows profile information", %{conn: conn} do
      conn = get conn, user_path(conn, :profile)
      assert html_response(conn, 200) =~ "user@email.com"
    end

    test "shows edit profile", %{conn: conn} do
      conn = get conn, user_path(conn, :edit_profile)
      assert html_response(conn, 200) =~ "Profile"
    end
  end

 
  describe "update user" do
    setup [:authenticate]

    test "redirects when data is valid", %{conn: conn} do
      user = get_default_user()

      conn = put conn, user_path(conn, :update), user: @update_attrs
      assert redirected_to(conn) == user_path(conn, :profile)

      assert "another@email.com" == Accounts.get_user!(user.id).email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put conn, user_path(conn, :update), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Profile"
    end
  end
end

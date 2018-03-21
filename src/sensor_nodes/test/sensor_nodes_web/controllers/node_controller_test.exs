defmodule SensorNodesWeb.NodeControllerTest do
  use SensorNodesWeb.ConnCase
  import SensorNodesWeb.ControllersHelper
  alias SensorNodes.Sensors

  @create_attrs %{"node_uid" => "some node_uid"}
  @update_attrs %{node_uid: "some updated node_uid"}
  @invalid_attrs %{node_uid: nil}

  def fixture(:node) do
    user = get_default_user()

    {:ok, node} = Sensors.create_node(user.id, @create_attrs)
    node
  end

  describe "index" do
    setup [:authenticate]

    test "lists all nodes", %{conn: conn} do
      conn = get conn, node_path(conn, :index)
      assert html_response(conn, 200) =~ "In this page you can manage your registered node controllers"
    end
  end

  describe "new node" do
    setup [:authenticate]

    test "renders form", %{conn: conn} do
      conn = get conn, node_path(conn, :new)
      assert html_response(conn, 200) =~ "New Node Controller"
    end
  end

  describe "create node" do
    setup [:authenticate]
    
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, node_path(conn, :create), node: @create_attrs
      assert redirected_to(conn) == node_path(conn, :index)

      {:ok, conn} = authenticate(%{conn: build_conn()}) 

      conn = get conn[:conn], node_path(conn[:conn], :index)
      assert html_response(conn, 200) =~ "some node_uid"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, node_path(conn, :create), node: @invalid_attrs
      assert html_response(conn, 200) =~ "New Node Controller"
    end
  end

  describe "edit node" do
    setup [:authenticate, :create_node]

    test "renders form for editing chosen node", %{conn: conn, node: node} do
      conn = get conn, node_path(conn, :edit, node)
      assert html_response(conn, 200) =~ "Edit Node"
    end
  end

  describe "update node" do
    setup [:authenticate, :create_node]

    test "redirects when data is valid", %{conn: conn, node: node} do
      conn = put conn, node_path(conn, :update, node), node: @update_attrs
      assert redirected_to(conn) == node_path(conn, :index)

      {:ok, conn} = authenticate(%{conn: build_conn()}) 

      conn = get conn[:conn], node_path(conn[:conn], :index)
      assert html_response(conn, 200) =~ "some updated node_uid"
    end

    test "renders errors when data is invalid", %{conn: conn, node: node} do
      conn = put conn, node_path(conn, :update, node), node: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Node"
    end
  end

  describe "delete node" do
    setup [:authenticate, :create_node]

    test "deletes chosen node", %{conn: conn, node: node} do
      conn = delete conn, node_path(conn, :delete, node)
      assert redirected_to(conn) == node_path(conn, :index)
      
      assert Sensors.list_nodes(get_default_user().id) == []

      {:ok, conn} = authenticate(%{conn: build_conn()}) 

      conn = get conn[:conn], node_path(conn[:conn], :index)
      assert !(html_response(conn, 200) =~ "node_uid")

    end
  end

  defp create_node(_) do
    node = fixture(:node)
    {:ok, node: node}
  end
end

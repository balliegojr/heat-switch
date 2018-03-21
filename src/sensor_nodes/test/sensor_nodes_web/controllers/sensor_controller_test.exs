defmodule SensorNodesWeb.SensorControllerTest do
  use SensorNodesWeb.ConnCase
  import SensorNodesWeb.ControllersHelper

  alias SensorNodes.Sensors

  @create_attrs %{lower: 120.5, op_mode: "some op_mode", relay_status: true, sensor_uid: "some sensor_uid", upper: 120.5}
  @update_attrs %{lower: 456.7, op_mode: "some updated op_mode", relay_status: false, sensor_uid: "some updated sensor_uid", upper: 456.7}
  @invalid_attrs %{lower: nil, op_mode: nil, relay_status: nil, sensor_uid: nil, upper: nil}

  def fixture(:sensor) do
    user = get_default_user()
    {:ok, node} = Sensors.create_node(user.id, %{ "node_uid" => "node_uid" })

    {:ok, sensor} = Sensors.create_sensor(Map.merge(@create_attrs, %{user_id: user.id, node_id: node.id}))
    sensor
  end

  setup [:authenticate]

  describe "index" do
    setup [:create_sensor]
  
    test "lists all sensors", %{conn: conn} do
      conn = get conn, sensor_path(conn, :index)
      assert html_response(conn, 200) =~ "In this page you can view and manage your sensors. They will appear here as soon as they become active in the node controller"
    end

    test "lists all sensors of a given node", %{conn: conn} do
      node = Sensors.get_node_by_uid!("node_uid")

      conn = get conn, node_sensor_path(conn, :filter_by_node, node)
      assert html_response(conn, 200) =~ "sensor_uid"
    end

  end

  describe "edit sensor" do
    setup [:create_sensor]

    test "renders form for editing chosen sensor", %{conn: conn, sensor: sensor} do
      conn = get conn, sensor_path(conn, :edit, sensor)
      assert html_response(conn, 200) =~ "Edit Sensor"
    end
  end

  describe "update sensor" do
    setup [:create_sensor]

    test "redirects when data is valid", %{conn: conn, sensor: sensor} do
      conn = put conn, sensor_path(conn, :update, sensor), sensor: @update_attrs
      assert redirected_to(conn) == sensor_path(conn, :show, sensor)

      {:ok, conn} = authenticate(%{conn: build_conn()}) 

      conn = get conn[:conn], sensor_path(conn[:conn], :index)
      assert html_response(conn, 200) =~ "some updated op_mode"
    end

    test "renders errors when data is invalid", %{conn: conn, sensor: sensor} do
      conn = put conn, sensor_path(conn, :update, sensor), sensor: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sensor"
    end
  end

  describe "delete sensor" do
    setup [:create_sensor]

    test "deletes chosen sensor", %{conn: conn, sensor: sensor} do
      conn = delete conn, sensor_path(conn, :delete, sensor)
      assert redirected_to(conn) == sensor_path(conn, :index)

      {:ok, conn} = authenticate(%{conn: build_conn()}) 
      conn = get conn[:conn], sensor_path(conn[:conn], :index)
      assert !(html_response(conn, 200) =~ "sensor_uid")
    end
  end

  defp create_sensor(_) do
    sensor = fixture(:sensor)
    {:ok, sensor: sensor}
  end
end

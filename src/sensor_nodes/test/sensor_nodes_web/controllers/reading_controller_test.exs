defmodule SensorNodesWeb.ReadingControllerTest do
  use SensorNodesWeb.ConnCase
  import SensorNodesWeb.ControllersHelper
  alias SensorNodes.Sensors.{Node, Sensor}

  describe "Unauthenticated requests" do
    test "index", %{conn: conn} do
      conn = get conn, reading_path(conn, :index)
      assert html_response(conn, 302)
    end

    test "filter_by_sensor", %{conn: conn} do
      conn = get conn, sensor_reading_path(conn, :filter_by_sensor, %Sensor{ id: 1})
      assert html_response(conn, 302)
    end

    test "filter_by_node", %{conn: conn} do
      conn = get conn, node_reading_path(conn, :filter_by_node, %Node{ id: 1})
      assert html_response(conn, 302)
    end
  end

  describe "authenticaated requests" do
    setup [:authenticate]
    
    test "lists all readings", %{conn: conn} do
      conn = get conn, reading_path(conn, :index)
      assert html_response(conn, 200) =~ "In this page you can see the readings of your sensors"
    end

    test "filter_by_sensor", %{conn: conn} do
      conn = get conn, sensor_reading_path(conn, :filter_by_sensor, %Sensor{ id: 1})
      assert html_response(conn, 200) =~ "In this page you can see the readings of your sensors"
    end

    test "filter_by_node", %{conn: conn} do
      conn = get conn, node_reading_path(conn, :filter_by_node, %Node{ id: 1})
      assert html_response(conn, 200) =~ "In this page you can see the readings of your sensors"
    end
  end
end

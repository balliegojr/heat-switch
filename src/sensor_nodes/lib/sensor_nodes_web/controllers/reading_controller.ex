defmodule SensorNodesWeb.ReadingController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Sensors

  def index(conn, _params) do
    readings = Sensors.list_readings(Guardian.Plug.current_resource(conn).id)
    render(conn, "index.html", readings: readings)
  end

  def filter_by_sensor(conn, %{"sensor_id" => id}) do
    readings = Sensors.list_readings_by_sensor(Guardian.Plug.current_resource(conn).id, id)
    render(conn, "index.html", readings: readings)
  end

  def filter_by_node(conn, %{"node_id" => id}) do
    readings = Sensors.list_readings_by_sensor(Guardian.Plug.current_resource(conn).id, id)
    render(conn, "index.html", readings: readings)
  end


end

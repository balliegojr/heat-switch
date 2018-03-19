defmodule SensorNodesWeb.ReadingController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Sensors
  alias SensorNodes.Sensors.Reading

  def index(conn, _params) do
    readings = Sensors.list_readings()
    render(conn, "index.html", readings: readings)
  end

  def filter_by_sensor(conn, %{"sensor_id" => id}) do
    readings = Sensors.list_readings_by_sensor(id)
    render(conn, "index.html", readings: readings)
  end

  def filter_by_node(conn, %{"node_id" => id}) do
    readings = Sensors.list_readings_by_sensor(id)
    render(conn, "index.html", readings: readings)
  end

  def show(conn, %{"id" => id}) do
    reading = Sensors.get_reading!(id)
    render(conn, "show.html", reading: reading)
  end

end

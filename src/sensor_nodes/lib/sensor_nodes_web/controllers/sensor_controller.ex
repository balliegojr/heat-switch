defmodule SensorNodesWeb.SensorController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Sensors
  alias SensorNodes.Sensors.Sensor

  require SensorNodesWeb.Gettext

  def index(conn, _params) do
    sensors = Sensors.list_sensors()
    render(conn, "index.html", sensors: sensors)
  end

  def filter_by_node(conn, %{"node_id" => id}) do
    sensors = Sensors.list_sensors_by_node(id)
    render(conn, "index.html", sensors: sensors)
  end

  def show(conn, %{"id" => id}) do
    sensor = Sensors.get_sensor!(id)
    render(conn, "show.html", sensor: sensor)
  end

  def edit(conn, %{"id" => id}) do
    sensor = Sensors.get_sensor!(id)
    changeset = Sensors.change_sensor(sensor)
    render(conn, "edit.html", sensor: sensor, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sensor" => sensor_params}) do
    sensor = Sensors.get_sensor!(id)

    case Sensors.update_sensor(sensor, sensor_params) do
      {:ok, sensor} ->
        conn
        |> put_flash(:info, gettext("Sensor updated"))
        |> redirect(to: sensor_path(conn, :show, sensor))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sensor: sensor, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sensor = Sensors.get_sensor!(id)
    {:ok, _sensor} = Sensors.delete_sensor(sensor)

    conn
    |> put_flash(:info, gettext("Sensor deleted"))
    |> redirect(to: sensor_path(conn, :index))
  end
end

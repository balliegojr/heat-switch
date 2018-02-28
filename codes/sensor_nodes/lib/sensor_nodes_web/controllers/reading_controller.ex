defmodule SensorNodesWeb.ReadingController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Sensors
  alias SensorNodes.Sensors.Reading

  def index(conn, _params) do
    readings = Sensors.list_readings()
    render(conn, "index.html", readings: readings)
  end

  def new(conn, _params) do
    changeset = Sensors.change_reading(%Reading{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reading" => reading_params}) do
    case Sensors.create_reading(reading_params) do
      {:ok, reading} ->
        conn
        |> put_flash(:info, "Reading created successfully.")
        |> redirect(to: reading_path(conn, :show, reading))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reading = Sensors.get_reading!(id)
    render(conn, "show.html", reading: reading)
  end

  def edit(conn, %{"id" => id}) do
    reading = Sensors.get_reading!(id)
    changeset = Sensors.change_reading(reading)
    render(conn, "edit.html", reading: reading, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reading" => reading_params}) do
    reading = Sensors.get_reading!(id)

    case Sensors.update_reading(reading, reading_params) do
      {:ok, reading} ->
        conn
        |> put_flash(:info, "Reading updated successfully.")
        |> redirect(to: reading_path(conn, :show, reading))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", reading: reading, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reading = Sensors.get_reading!(id)
    {:ok, _reading} = Sensors.delete_reading(reading)

    conn
    |> put_flash(:info, "Reading deleted successfully.")
    |> redirect(to: reading_path(conn, :index))
  end
end

defmodule SensorNodesWeb.SensorView do
  use SensorNodesWeb, :view
  alias SensorNodesWeb.SensorView


  def render("sensors.json", %{sensors: sensors}) do
    render_many(sensors, SensorView, "sensor.json")
  end

  def render("sensor.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      name: sensor.name,
      upper: sensor.upper,
      lower: sensor.lower,
      sensor_uid: sensor.sensor_uid,
      relay_status: sensor.relay_status,
      op_mode: sensor.op_mode
     }
  end
end

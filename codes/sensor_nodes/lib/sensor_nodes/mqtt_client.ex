defmodule SensorNodes.MqttClient do
  use Hulaaki.Client

  alias SensorNodes.Sensors

  def on_subscribed_publish(options) do
    message = options |> Keyword.fetch!(:message)
    spawn(fn -> 
      [_, _, node_id, _, sensor_id, type] = String.split(message.topic, "/")
      Sensors.create_reading(node_id, sensor_id, type, message.message)  
    end)

    
  end

end
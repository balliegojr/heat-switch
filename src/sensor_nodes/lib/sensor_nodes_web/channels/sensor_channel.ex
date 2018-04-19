defmodule SensorNodesWeb.SensorChannel do
    use Phoenix.Channel

    def join("sensor:" <> sensorid, _message, socket) do
        {:ok, socket}
    end

    def join("dashboard:" <> userid, _message, socket) do
        {:ok, socket}
    end
end
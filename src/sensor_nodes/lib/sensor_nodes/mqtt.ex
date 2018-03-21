defmodule SensorNodes.Mqtt do
    use Agent

    alias SensorNodes.MqttClient

    
    def connect_and_subscribe() do
        {:ok, pid} = MqttClient.start_link(%{ parent: self() })

        if Application.get_env(:sensor_nodes, SensorNodes.Mqtt) != nil do
            MqttClient.connect(pid, Application.get_env(:sensor_nodes, SensorNodes.Mqtt))
            MqttClient.subscribe(pid, [topics: ["viper/node/+/sensor/#"], qoses: [0]])
        end

        {:ok, pid}
    end

    def start_link() do
        Agent.start_link(fn -> connect_and_subscribe() end, name: :mqtt)
    end

    defp topic(node_id, sensor_id) do 
        "viper/node/#{node_id}/set/#{sensor_id}/mode" 
    end

    defp send_message(topic, message) do
        Agent.cast(:mqtt, fn {:ok, pid}  -> 
            options = [topic: topic, message: message, dup: 0, qos: 0, retain: 0 ] 
            MqttClient.publish(pid, options)
            {:ok, pid}
        end)
    end

    
    
    def send_message(node_id, sensor_id, "R", _values) do
        topic(node_id, sensor_id)
        |> send_message("report")
    end
    
    def send_message(node_id, sensor_id, "A", %{ upper: upper, lower: lower }) do
        topic(node_id, sensor_id)
        |> send_message("automatic #{upper} #{lower}")
    end
    
    def send_message(node_id, sensor_id, "O", %{ relay_status: relay_status }) do
        message = case relay_status do
            true -> "override relay on"
            false -> "override relay off"
        end
        topic(node_id, sensor_id)
        |> send_message(message)
        
    end

    def send_message(_node_id, _sensor_id, _mode, _values) do
        nil
    end

end
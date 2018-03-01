defmodule SensorNodes.Mqtt do
    use Agent

    alias SensorNodes.MqttClient

    ## Client API

    @doc """
    Starts the registry.
    """
    def start_link() do

        {:ok, pid} = MqttClient.start_link(%{ parent: self() })
        MqttClient.connect(pid, Application.get_env(:sensor_nodes, SensorNodes.Mqtt))
        MqttClient.subscribe(pid, [topics: ["viper/node/#"], qoses: [0]])

        {:ok, pid}
    end

    # def init(table) do
    #     names = :ets.new(table, [:named_table, read_concurrency: true ])
    #     refs = %{}
    #     {:ok, {names, refs}}
    # end
end
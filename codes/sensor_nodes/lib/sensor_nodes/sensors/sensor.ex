defmodule SensorNodes.Sensors.Sensor do
  use Ecto.Schema
  import Ecto.Changeset
  alias SensorNodes.Sensors.Sensor


  schema "sensors" do
    field :lower, :float
    field :op_mode, :string
    field :name, :string
    field :relay_status, :boolean, default: false
    field :sensor_uid, :string
    field :upper, :float
    field :user_id, :id
    field :node_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Sensor{} = sensor, attrs) do
    sensor
    |> cast(attrs, [:sensor_uid, :op_mode, :relay_status, :upper, :lower, :node_id, :name])
    |> validate_required([:sensor_uid, :op_mode, :relay_status, :upper, :lower, :node_id])
  end
end

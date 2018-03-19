defmodule SensorNodes.Sensors.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  alias SensorNodes.Sensors.Reading


  schema "readings" do
    field :sensor_uid, :string
    field :type, :string
    field :value, :string
    field :user_id, :id
    field :sensor_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Reading{} = reading, attrs) do
    reading
    |> cast(attrs, [:sensor_uid, :type, :value, :sensor_id, :user_id])
    |> validate_required([:sensor_uid, :type, :value, :sensor_id, :user_id])
  end
end

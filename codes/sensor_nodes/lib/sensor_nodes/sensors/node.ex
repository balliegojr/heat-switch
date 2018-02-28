defmodule SensorNodes.Sensors.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias SensorNodes.Sensors.Node


  schema "nodes" do
    field :node_uid, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [:node_uid])
    |> validate_required([:node_uid])
  end
end

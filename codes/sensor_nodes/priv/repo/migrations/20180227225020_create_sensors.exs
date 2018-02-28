defmodule SensorNodes.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :sensor_uid, :string
      add :op_mode, :string
      add :relay_status, :boolean, default: false, null: false
      add :upper, :float
      add :lower, :float
      add :user_id, references(:users, on_delete: :nothing)
      add :node_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:sensors, [:user_id])
    create index(:sensors, [:node_id])
    create index(:sensors, [:sensor_uid])
  end
end

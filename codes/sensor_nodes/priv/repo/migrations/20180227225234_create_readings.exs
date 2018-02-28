defmodule SensorNodes.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :sensor_uid, :string
      add :type, :string
      add :value, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :sensor_id, references(:sensors, on_delete: :nothing)

      timestamps()
    end

    create index(:readings, [:user_id])
    create index(:readings, [:sensor_id])
    create index(:readings, [:sensor_uid])
  end
end

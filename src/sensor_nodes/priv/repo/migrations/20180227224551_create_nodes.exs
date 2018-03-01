defmodule SensorNodes.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :node_uid, :string
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:nodes, [:user_id])
    create index(:nodes, [:node_uid])
  end
end

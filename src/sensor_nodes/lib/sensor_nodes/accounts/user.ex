defmodule SensorNodes.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias SensorNodes.Accounts.User


  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end

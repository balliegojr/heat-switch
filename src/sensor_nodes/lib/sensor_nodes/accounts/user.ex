defmodule SensorNodes.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import SensorNodesWeb.Gettext
  alias SensorNodes.Accounts.User
  alias Comeonin.Bcrypt

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_confirmation(:password, message: SensorNodesWeb.Gettext.gettext("Password does not match"))
    |> unique_constraint(:email, message: SensorNodesWeb.Gettext.gettext("Email already in use"))
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hashpwsalt(password))
  end
  defp put_pass_hash(changeset), do: changeset
end

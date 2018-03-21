defmodule SensorNodes.AccountsTest do
  use SensorNodes.DataCase

  alias SensorNodes.Accounts

  describe "users" do
    alias SensorNodes.Accounts.User

    @valid_attrs %{email: "some email", password: "some password", password_confirmation: "some password"}
    @update_attrs %{email: "some updated email", password: "some updated password", password_confirmation: "some updated password"}
    @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      Map.merge(user, %{password_confirmation: nil, password: nil})
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.password == "some password"
      assert user.password_hash != nil
    end

    test "create_user/1 validates unique constraint" do
      user_fixture()

      assert {:error, %{ errors: [email: {"Email already in use", []}]}} = Accounts.create_user(@valid_attrs)
    end

    test "create_user/1 validates password confirmation" do
      user_wrong_confirmation = %{email: "some email", password: "some password", password_confirmation: "wrong confirmation"}
      assert {:error, %{ errors: [password_confirmation: {"Password does not match", [validation: :confirmation]}]}} = Accounts.create_user(user_wrong_confirmation)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 verify if password match the database" do
      user = user_fixture()

      assert {:ok, ^user}  = Accounts.authenticate_user(user.email, @valid_attrs.password)
    end

    test "authenticate_user/2 verify if password match the database with wrong password" do
      user = user_fixture()

      assert {:error, "Incorrect username or password"}  = Accounts.authenticate_user(user.email, "wrong password")
    end
  end
end

defmodule SensorNodesWeb.UserController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Accounts
 
  def edit_profile(conn, _params) do
    user = Accounts.get_user!(Guardian.Plug.current_resource(conn).id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def profile(conn, _params) do
    user = Accounts.get_user!(Guardian.Plug.current_resource(conn).id)
    render(conn, "show.html", user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = Accounts.get_user!(Guardian.Plug.current_resource(conn).id)

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: user_path(conn, :profile))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   user = Accounts.get_user!(id)
  #   {:ok, _user} = Accounts.delete_user(user)

  #   conn
  #   |> put_flash(:info, "User deleted successfully.")
  #   |> redirect(to: user_path(conn, :index))
  # end
end

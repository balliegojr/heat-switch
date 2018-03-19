defmodule SensorNodes.Auth.ErrorHandler do
  import Plug.Conn
  import SensorNodesWeb.Gettext

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
      |> Phoenix.Controller.put_flash(:info, gettext("You are not authorized to see this page"))
      |> Phoenix.Controller.redirect(to: "/")
  end
end
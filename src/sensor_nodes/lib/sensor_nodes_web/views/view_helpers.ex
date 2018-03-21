defmodule SensorNodesWeb.ViewHelpers do
    alias SensorNodes.Auth.Guardian

    def authenticated?(conn) do
        Guardian.Plug.authenticated?(conn)
    end

    def current_user(conn) do
        Guardian.Plug.current_resource(conn)
    end

    def locale(conn) do
        conn.params["locale"] || Plug.Conn.get_session(conn, :locale)
    end
end
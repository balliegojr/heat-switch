defmodule SensorNodesWeb.NodeController do
  use SensorNodesWeb, :controller

  alias SensorNodes.Sensors
  alias SensorNodes.Sensors.Node
  require SensorNodesWeb.Gettext

  def index(conn, _params) do
    nodes = Sensors.list_nodes(Guardian.Plug.current_resource(conn).id)
    render(conn, "index.html", nodes: nodes)
  end

  def new(conn, _params) do
    changeset = Sensors.change_node(%Node{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"node" => node_params}) do
    case Sensors.create_node(Guardian.Plug.current_resource(conn).id, node_params) do
      {:ok, node} ->
        conn
        |> put_flash(:info, gettext("Node controller created"))
        |> redirect(to: node_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    node = Sensors.get_node!(Guardian.Plug.current_resource(conn).id, id)
    changeset = Sensors.change_node(node)
    render(conn, "edit.html", node: node, changeset: changeset)
  end

  def update(conn, %{"id" => id, "node" => node_params}) do
    node = Sensors.get_node!(Guardian.Plug.current_resource(conn).id, id)

    case Sensors.update_node(node, node_params) do
      {:ok, node} ->
        conn
        |> put_flash(:info, gettext("Node controller updated"))
        |> redirect(to: node_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", node: node, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Sensors.get_node!(Guardian.Plug.current_resource(conn).id, id)
    {:ok, _node} = Sensors.delete_node(node)

    conn
    |> put_flash(:info, gettext("Node controller removed"))
    |> redirect(to: node_path(conn, :index))
  end
end

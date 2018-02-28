defmodule SensorNodesWeb.ReadingControllerTest do
  use SensorNodesWeb.ConnCase

  alias SensorNodes.Sensors

  @create_attrs %{sensor_uid: "some sensor_uid", type: "some type", value: "some value"}
  @update_attrs %{sensor_uid: "some updated sensor_uid", type: "some updated type", value: "some updated value"}
  @invalid_attrs %{sensor_uid: nil, type: nil, value: nil}

  def fixture(:reading) do
    {:ok, reading} = Sensors.create_reading(@create_attrs)
    reading
  end

  describe "index" do
    test "lists all readings", %{conn: conn} do
      conn = get conn, reading_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Readings"
    end
  end

  describe "new reading" do
    test "renders form", %{conn: conn} do
      conn = get conn, reading_path(conn, :new)
      assert html_response(conn, 200) =~ "New Reading"
    end
  end

  describe "create reading" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, reading_path(conn, :create), reading: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == reading_path(conn, :show, id)

      conn = get conn, reading_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Reading"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, reading_path(conn, :create), reading: @invalid_attrs
      assert html_response(conn, 200) =~ "New Reading"
    end
  end

  describe "edit reading" do
    setup [:create_reading]

    test "renders form for editing chosen reading", %{conn: conn, reading: reading} do
      conn = get conn, reading_path(conn, :edit, reading)
      assert html_response(conn, 200) =~ "Edit Reading"
    end
  end

  describe "update reading" do
    setup [:create_reading]

    test "redirects when data is valid", %{conn: conn, reading: reading} do
      conn = put conn, reading_path(conn, :update, reading), reading: @update_attrs
      assert redirected_to(conn) == reading_path(conn, :show, reading)

      conn = get conn, reading_path(conn, :show, reading)
      assert html_response(conn, 200) =~ "some updated sensor_uid"
    end

    test "renders errors when data is invalid", %{conn: conn, reading: reading} do
      conn = put conn, reading_path(conn, :update, reading), reading: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Reading"
    end
  end

  describe "delete reading" do
    setup [:create_reading]

    test "deletes chosen reading", %{conn: conn, reading: reading} do
      conn = delete conn, reading_path(conn, :delete, reading)
      assert redirected_to(conn) == reading_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, reading_path(conn, :show, reading)
      end
    end
  end

  defp create_reading(_) do
    reading = fixture(:reading)
    {:ok, reading: reading}
  end
end

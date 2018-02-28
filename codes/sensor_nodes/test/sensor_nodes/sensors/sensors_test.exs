defmodule SensorNodes.SensorsTest do
  use SensorNodes.DataCase

  alias SensorNodes.Sensors

  describe "nodes" do
    alias SensorNodes.Sensors.Node

    @valid_attrs %{node_uid: "some node_uid"}
    @update_attrs %{node_uid: "some updated node_uid"}
    @invalid_attrs %{node_uid: nil}

    def node_fixture(attrs \\ %{}) do
      {:ok, node} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_node()

      node
    end

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Sensors.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Sensors.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      assert {:ok, %Node{} = node} = Sensors.create_node(@valid_attrs)
      assert node.node_uid == "some node_uid"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      assert {:ok, node} = Sensors.update_node(node, @update_attrs)
      assert %Node{} = node
      assert node.node_uid == "some updated node_uid"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Sensors.update_node(node, @invalid_attrs)
      assert node == Sensors.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Sensors.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Sensors.change_node(node)
    end
  end

  describe "sensors" do
    alias SensorNodes.Sensors.Sensor

    @valid_attrs %{lower: 120.5, op_mode: "some op_mode", relay_status: true, sensor_uid: "some sensor_uid", upper: 120.5}
    @update_attrs %{lower: 456.7, op_mode: "some updated op_mode", relay_status: false, sensor_uid: "some updated sensor_uid", upper: 456.7}
    @invalid_attrs %{lower: nil, op_mode: nil, relay_status: nil, sensor_uid: nil, upper: nil}

    def sensor_fixture(attrs \\ %{}) do
      {:ok, sensor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_sensor()

      sensor
    end

    test "list_sensors/0 returns all sensors" do
      sensor = sensor_fixture()
      assert Sensors.list_sensors() == [sensor]
    end

    test "get_sensor!/1 returns the sensor with given id" do
      sensor = sensor_fixture()
      assert Sensors.get_sensor!(sensor.id) == sensor
    end

    test "create_sensor/1 with valid data creates a sensor" do
      assert {:ok, %Sensor{} = sensor} = Sensors.create_sensor(@valid_attrs)
      assert sensor.lower == 120.5
      assert sensor.op_mode == "some op_mode"
      assert sensor.relay_status == true
      assert sensor.sensor_uid == "some sensor_uid"
      assert sensor.upper == 120.5
    end

    test "create_sensor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_sensor(@invalid_attrs)
    end

    test "update_sensor/2 with valid data updates the sensor" do
      sensor = sensor_fixture()
      assert {:ok, sensor} = Sensors.update_sensor(sensor, @update_attrs)
      assert %Sensor{} = sensor
      assert sensor.lower == 456.7
      assert sensor.op_mode == "some updated op_mode"
      assert sensor.relay_status == false
      assert sensor.sensor_uid == "some updated sensor_uid"
      assert sensor.upper == 456.7
    end

    test "update_sensor/2 with invalid data returns error changeset" do
      sensor = sensor_fixture()
      assert {:error, %Ecto.Changeset{}} = Sensors.update_sensor(sensor, @invalid_attrs)
      assert sensor == Sensors.get_sensor!(sensor.id)
    end

    test "delete_sensor/1 deletes the sensor" do
      sensor = sensor_fixture()
      assert {:ok, %Sensor{}} = Sensors.delete_sensor(sensor)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_sensor!(sensor.id) end
    end

    test "change_sensor/1 returns a sensor changeset" do
      sensor = sensor_fixture()
      assert %Ecto.Changeset{} = Sensors.change_sensor(sensor)
    end
  end

  describe "readings" do
    alias SensorNodes.Sensors.Reading

    @valid_attrs %{sensor_uid: "some sensor_uid", type: "some type", value: "some value"}
    @update_attrs %{sensor_uid: "some updated sensor_uid", type: "some updated type", value: "some updated value"}
    @invalid_attrs %{sensor_uid: nil, type: nil, value: nil}

    def reading_fixture(attrs \\ %{}) do
      {:ok, reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_reading()

      reading
    end

    test "list_readings/0 returns all readings" do
      reading = reading_fixture()
      assert Sensors.list_readings() == [reading]
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = reading_fixture()
      assert Sensors.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a reading" do
      assert {:ok, %Reading{} = reading} = Sensors.create_reading(@valid_attrs)
      assert reading.sensor_uid == "some sensor_uid"
      assert reading.type == "some type"
      assert reading.value == "some value"
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading" do
      reading = reading_fixture()
      assert {:ok, reading} = Sensors.update_reading(reading, @update_attrs)
      assert %Reading{} = reading
      assert reading.sensor_uid == "some updated sensor_uid"
      assert reading.type == "some updated type"
      assert reading.value == "some updated value"
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Sensors.update_reading(reading, @invalid_attrs)
      assert reading == Sensors.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{}} = Sensors.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = reading_fixture()
      assert %Ecto.Changeset{} = Sensors.change_reading(reading)
    end
  end
end

defmodule SensorNodes.SensorsTest do
  use SensorNodes.DataCase

  alias SensorNodes.Sensors
  alias SensorNodes.Accounts

  describe "nodes" do
    alias SensorNodes.Sensors.Node

    def create_user do 
      { :ok, user } = Accounts.create_user(%{email: "email", password: "some password", password_confirmation: "some password"})
      user
    end
    

    @valid_attrs %{"node_uid" => "some node_uid"}
    @update_attrs %{"node_uid" => "some updated node_uid"}
    @invalid_attrs %{"node_uid" => nil}


    def node_fixture(user_id, attrs \\ %{}) do
      attrs = attrs
      |> Enum.into(@valid_attrs)
      
      {:ok, node} = Sensors.create_node(user_id, attrs)

      node
    end

    test "list_nodes/1 returns all nodes from a given user" do
      user = create_user()
      node = node_fixture(user.id)
      assert Sensors.list_nodes(user.id) == [node]
      assert Sensors.list_nodes(0) == []
    end

    test "get_node!/2 returns the node with given id from a given user" do
      user = create_user()
      
      node = node_fixture(user.id)
      assert Sensors.get_node!(user.id, node.id) == node
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_node!(0, node.id) end
    end

    test "get_node_by_uid!/1 returns the node with given uid" do
      user = create_user()
      
      node = node_fixture(user.id)
      assert Sensors.get_node_by_uid!("some node_uid") == node
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_node_by_uid!("wrong uid") end
    end

    test "create_node/2 with valid data creates a node" do
      user = create_user()
      
      assert {:ok, %Node{} = node} = Sensors.create_node(user.id, @valid_attrs)
      assert node.node_uid == "some node_uid"
      assert node.user_id == user.id
    end

    test "create_node/2 with invalid data returns error changeset" do
      user = create_user()
      
      assert {:error, %Ecto.Changeset{}} = Sensors.create_node(user.id, @invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      user = create_user()
      
      node = node_fixture(user.id)
      assert {:ok, node} = Sensors.update_node(node, @update_attrs)
      assert %Node{} = node
      assert node.node_uid == "some updated node_uid"
    end

    test "update_node/2 with invalid data returns error changeset" do
      user = create_user()
      
      node = node_fixture(user.id)
      assert {:error, %Ecto.Changeset{}} = Sensors.update_node(node, @invalid_attrs)
      assert node == Sensors.get_node!(user.id, node.id)
    end

    test "delete_node/2 deletes the node" do
      user = create_user()
      node = node_fixture(user.id)
      assert {:ok, %Node{}} = Sensors.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_node!(user.id, node.id) end
    end

    test "change_node/1 returns a node changeset" do
      user = create_user()
      node = node_fixture(user.id)
      assert %Ecto.Changeset{} = Sensors.change_node(node)
    end
  end

  describe "sensors" do
    alias SensorNodes.Sensors.Sensor

    @valid_attrs %{lower: 120.5, op_mode: "some op_mode", name: "some name", relay_status: true, sensor_uid: "some sensor_uid", upper: 120.5}
    @update_attrs %{lower: 456.7, op_mode: "some updated op_mode", name: "some updated name", relay_status: false, sensor_uid: "some updated sensor_uid", upper: 456.7}
    @invalid_attrs %{lower: nil, op_mode: nil, relay_status: nil, sensor_uid: nil, upper: nil}

    def sensor_fixture(attrs \\ %{}) do
      {:ok, sensor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_sensor()

      sensor
    end

    test "list_sensors/1 returns all sensors of a given user" do
      user = create_user()
      node = node_fixture(user.id)

      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })
      assert Sensors.list_sensors(user.id) == [sensor]
      assert Sensors.list_sensors(0) == []
    end

    test "list_sensors_by_node/2 returns all sensors of given user and node" do
      user = create_user()
      node = node_fixture(user.id)

      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })
      assert Sensors.list_sensors_by_node(user.id, node.id) == [sensor]
    end

    test "get_sensor!/2 returns the sensor with given id and user_id" do
      user = create_user()
      node = node_fixture(user.id)

      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })
      assert Sensors.get_sensor!(user.id, sensor.id) == sensor
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_sensor!(0, sensor.id) end
    end

    test "get_sensor_by_uid/2 returns the sensor with given uid" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert Sensors.get_sensor_by_uid(user.id, sensor.sensor_uid) == sensor
      assert nil == Sensors.get_sensor_by_uid(user.id, "wrong uid")
    end


    test "create_sensor/1 with valid data creates a sensor" do
      user = create_user()
      node = node_fixture(user.id)

      assert {:ok, %Sensor{} = sensor} = Sensors.create_sensor(Map.merge(@valid_attrs, %{user_id: user.id, node_id: node.id}))
      assert sensor.lower == 120.5
      assert sensor.op_mode == "some op_mode"
      assert sensor.relay_status == true
      assert sensor.sensor_uid == "some sensor_uid"
      assert sensor.upper == 120.5
      assert sensor.name == "some name"
      assert sensor.user_id == user.id
      assert sensor.node_id == node.id
    end

    test "create_sensor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_sensor(@invalid_attrs)
    end

    test "update_sensor/2 with valid data updates the sensor" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert {:ok, sensor} = Sensors.update_sensor(sensor, @update_attrs)
      assert %Sensor{} = sensor
      assert sensor.lower == 456.7
      assert sensor.op_mode == "some updated op_mode"
      assert sensor.relay_status == false
      assert sensor.sensor_uid == "some updated sensor_uid"
      assert sensor.upper == 456.7
      assert sensor.name == "some updated name"
    end

    test "update_sensor/2 with invalid data returns error changeset" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert {:error, %Ecto.Changeset{}} = Sensors.update_sensor(sensor, @invalid_attrs)
      assert sensor == Sensors.get_sensor!(user.id, sensor.id)
    end

    test "delete_sensor/1 deletes the sensor" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert {:ok, %Sensor{}} = Sensors.delete_sensor(sensor)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_sensor!(user.id, sensor.id) end
    end

    test "change_sensor/1 returns a sensor changeset" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert %Ecto.Changeset{} = Sensors.change_sensor(sensor)
    end
  end

  describe "readings" do
    alias SensorNodes.Sensors.Reading
    alias SensorNodes.Sensors.Sensor

    @valid_attrs %{sensor_uid: "some sensor_uid", type: "some type", value: "some value", sensor_id: 1, node_id: 1}
    @invalid_attrs %{sensor_uid: nil, type: nil, value: nil}

    def reading_fixture(attrs \\ %{}) do
      {:ok, reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_reading()

      reading
    end

    test "list_readings/1 returns all readings of a given user" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      reading = reading_fixture(%{ user_id: user.id, sensor_id: sensor.id})
      assert Sensors.list_readings(user.id) == [reading]
      assert Sensors.list_readings(0) == []
    end

    test "list_readings_by_sensor/2 returns all readings of a given user and sensor" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      reading = reading_fixture(%{ user_id: user.id, sensor_id: sensor.id})
      assert Sensors.list_readings_by_sensor(user.id, sensor.id) == [reading]
      assert Sensors.list_readings_by_sensor(user.id, 0) == []
    end

    test "list_readings_by_node/2 returns all readings of a given user and node" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      reading = reading_fixture(%{ user_id: user.id, sensor_id: sensor.id})
      assert Sensors.list_readings_by_node(user.id, node.id) == [reading]
      assert Sensors.list_readings_by_node(user.id, 0) == []
      
    end


    test "get_reading!/2 returns the reading with given id and user_id" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      reading = reading_fixture(%{ user_id: user.id, sensor_id: sensor.id})

      assert Sensors.get_reading!(user.id, reading.id) == reading
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_reading!(0, reading.id) end
    end

    test "create_reading/1 with valid data creates a reading" do
      user = create_user()
      node = node_fixture(user.id)
      sensor = sensor_fixture(%{ user_id: user.id, node_id: node.id })

      assert {:ok, %Reading{} = reading} = Sensors.create_reading(Map.merge(@valid_attrs, %{ user_id: user.id, sensor_id: sensor.id}))
      assert reading.sensor_uid == "some sensor_uid"
      assert reading.type == "some type"
      assert reading.value == "some value"
      assert reading.user_id == user.id
      assert reading.sensor_id == sensor.id
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_reading(@invalid_attrs)
    end


    test "create_reading/4 with 'id' creates a new sensor" do
      user = create_user()
      node = node_fixture(user.id)
      
      assert {:ok, %Sensor{} = sensor} = Sensors.create_reading(node.node_uid, "sensor_id", "id", "id:sensor_id")
      assert sensor.sensor_uid == "sensor_id"
    end

    test "create_reading/4 with 'relay' creates a new reading and change sensor status when sensor mode is different of 'O'" do
      user = create_user()
      node = node_fixture(user.id)
      
      assert {:ok, %Reading{} = reading} = Sensors.create_reading(node.node_uid, "sensor_id", "relay", "on")
      assert reading.type == "relay"

      assert sensor = Sensors.get_sensor_by_uid(user.id, "sensor_id")
      assert sensor.op_mode != "O"
      assert sensor.relay_status == true

      Sensors.create_reading(node.node_uid, "sensor_id", "relay", "off")
      assert sensor = Sensors.get_sensor_by_uid(user.id, "sensor_id")
      assert sensor.relay_status == false

      Sensors.update_sensor(sensor, %{:op_mode => "O"})
      Sensors.create_reading(node.node_uid, "sensor_id", "relay", "on")
      
      assert sensor = Sensors.get_sensor_by_uid(user.id, "sensor_id")
      assert sensor.relay_status == false

      assert [ sensor ] == Sensors.list_sensors(user.id)
      assert 2 == Enum.count(Sensors.list_readings(user.id))
    end


    test "create_reading/4 create a new reading" do
      user = create_user()
      node = node_fixture(user.id)
      
      assert {:ok, %Reading{} = reading} = Sensors.create_reading(node.node_uid, "sensor_id", "temperature", "28")
      assert reading.type == "temperature"
      assert reading.value == "28"

      assert sensor = Sensors.get_sensor_by_uid(user.id, "sensor_id")
      assert sensor.op_mode == "A"
    end
   
  end
end

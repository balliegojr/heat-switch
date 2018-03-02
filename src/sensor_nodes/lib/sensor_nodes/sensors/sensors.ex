defmodule SensorNodes.Sensors do
  @moduledoc """
  The Sensors context.
  """

  import Ecto.Query, warn: false
  alias SensorNodes.Repo

  alias SensorNodes.Sensors.Node

  @doc """
  Returns the list of nodes.

  ## Examples

      iex> list_nodes()
      [%Node{}, ...]

  """
  def list_nodes do
    Repo.all(Node)
  end

  @doc """
  Gets a single node.

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

      iex> get_node!(123)
      %Node{}

      iex> get_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_node!(id), do: Repo.get!(Node, id)

  def get_node_by_uid(uid) do
    Repo.get_by(Node, node_uid: uid)
  end

  @doc """
  Creates a node.

  ## Examples

      iex> create_node(%{field: value})
      {:ok, %Node{}}

      iex> create_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_node(attrs \\ %{}) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a node.

  ## Examples

      iex> update_node(node, %{field: new_value})
      {:ok, %Node{}}

      iex> update_node(node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Node.

  ## Examples

      iex> delete_node(node)
      {:ok, %Node{}}

      iex> delete_node(node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_node(%Node{} = node) do
    Repo.delete(node)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking node changes.

  ## Examples

      iex> change_node(node)
      %Ecto.Changeset{source: %Node{}}

  """
  def change_node(%Node{} = node) do
    Node.changeset(node, %{})
  end

  alias SensorNodes.Sensors.Sensor

  @doc """
  Returns the list of sensors.

  ## Examples

      iex> list_sensors()
      [%Sensor{}, ...]

  """
  def list_sensors do
    Repo.all(Sensor)
  end

  def list_sensors_by_node (node_id) do 
    Repo.all(from sensor in Sensor, where: sensor.node_id == ^node_id )
  end

  @doc """
  Gets a single sensor.

  Raises `Ecto.NoResultsError` if the Sensor does not exist.

  ## Examples

      iex> get_sensor!(123)
      %Sensor{}

      iex> get_sensor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor!(id), do: Repo.get!(Sensor, id)

  def get_sensor_by_uid(uid) do
    Repo.get_by(Sensor, sensor_uid: uid)
  end
  @doc """
  Creates a sensor.

  ## Examples

      iex> create_sensor(%{field: value})
      {:ok, %Sensor{}}

      iex> create_sensor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor(attrs \\ %{}) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sensor.

  ## Examples

      iex> update_sensor(sensor, %{field: new_value})
      {:ok, %Sensor{}}

      iex> update_sensor(sensor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor(%Sensor{} = sensor, attrs) do
    sensor
    |> Sensor.changeset(attrs)
    |> Repo.update()
    |> trigger_mqtt_commands()
  end

  @doc """
  Deletes a Sensor.

  ## Examples

      iex> delete_sensor(sensor)
      {:ok, %Sensor{}}

      iex> delete_sensor(sensor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor(%Sensor{} = sensor) do
    Repo.delete(sensor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor changes.

  ## Examples

      iex> change_sensor(sensor)
      %Ecto.Changeset{source: %Sensor{}}

  """
  def change_sensor(%Sensor{} = sensor) do
    Sensor.changeset(sensor, %{})
  end

  alias SensorNodes.Sensors.Reading

  @doc """
  Returns the list of readings.

  ## Examples

      iex> list_readings()
      [%Reading{}, ...]

  """
  def list_readings do
    Repo.all(from reading in Reading, order_by: [desc: :inserted_at])
  end

  def list_readings_by_sensor(sensor_id) do
    Repo.all(from reading in Reading, where: reading.sensor_id == ^sensor_id, order_by: [desc: :inserted_at])
  end

  def list_readings_by_node(node_id) do
    query = from reading in Reading, 
      join: sensor in Sensor,
      where: sensor.id == reading.sensor_id and sensor.node_id == ^node_id,
      order_by: [desc: :inserted_at]
    Repo.all(query)
  end

  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the Reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id), do: Repo.get!(Reading, id)

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end


  defp get_sensor_or_create(sensor_uid, node_uid) do
    sensor = get_sensor_by_uid(sensor_uid)
    if sensor == nil do
        node = get_node_by_uid(node_uid)

        if node != nil do
            sensor_info = %{
                :user_id => node.user_id,
                :node_id => node.id,
                :sensor_uid => sensor_uid,
                :upper => 32,
                :lower => 28,
                :op_mode => "A"
            }

            sensor = create_sensor(sensor_info)
        end
    end
        
    sensor
  end


  def create_reading(node_id, _sensor_id, "id", reading) do
    node = get_node_by_uid(node_id)
    if node != nil do
        info = Map.new Enum.map String.split(reading, ";"), fn(item) -> 
            [key, value] = String.split(item, ":")
            {key, value}
        end
    
        sensor_info = %{
            :lower => info["lower"],
            :op_mode => info["op_mode"],
            :relay_status => false,
            :sensor_uid => info["id"],
            :upper => :info["upper"],
            :user_id => node.user_id,
            :node_id => node.id
        }
        
        create_sensor(sensor_info)
    end
  end

  def create_reading(node_id, sensor_id, "relay", reading) do
    sensor = get_sensor_or_create(sensor_id, node_id)
    if sensor.op_mode != "O" do
        changeset = case String.replace(reading, "\r\n", "") do
            "on" -> Sensor.changeset(sensor, %{ :relay_status => true })
            "off" -> Sensor.changeset(sensor, %{ :relay_status => false })
        end

        Repo.update(changeset)
        reading_info = %{
            :sensor_uid => sensor_id,
            :type => "relay",
            :value => reading,
            :user_id => sensor.user_id,
            :sensor_id => sensor.id
        }

        create_reading(reading_info)    
    end
  end

  def create_reading(node_id, sensor_id, type, reading) do
    sensor = get_sensor_or_create(sensor_id, node_id)
    if sensor != nil do
        reading_info = %{
            :sensor_uid => sensor_id,
            :type => type,
            :value => reading,
            :user_id => sensor.user_id,
            :sensor_id => sensor.id
        }

        create_reading(reading_info)
    end
  end

  def trigger_mqtt_commands({:ok, sensor}) do
    spawn(fn -> 
        SensorNodes.Mqtt.send_message(
        get_node!(sensor.node_id).node_uid, 
        sensor.sensor_uid, 
        sensor.op_mode, 
        %{ :relay_status => sensor.relay_status, :upper => sensor.upper, :lower => sensor.lower })
        
    end)

    {:ok, sensor}
    
  end
end

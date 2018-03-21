defmodule SensorNodes.Sensors do
  @moduledoc """
  The Sensors context.
  """

  import Ecto.Query, warn: false
  alias SensorNodes.Repo

  alias SensorNodes.Sensors.Node

  @doc """
  Returns the list of nodes from a given `user_id`.

  ## Examples

      iex> list_nodes(user_id)
      [%Node{}, ...]

  """
  def list_nodes(user_id) do
    Repo.all(from f in Node, where: f.user_id == ^user_id)
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
  defp get_node!(id), do: Repo.get!(Node, id)
  def get_node!(user_id, id) do
    Repo.one!(from n in Node, where: n.id == ^id and n.user_id == ^user_id)
  end

  def get_node_by_uid!(uid) do
    Repo.get_by!(Node, node_uid: uid)
  end

  @doc """
  Creates a node.

  ## Examples

      iex> create_node(%{field: value})
      {:ok, %Node{}}

      iex> create_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_node(user_id, attrs \\ %{}) do
    %Node{}
    |> Node.changeset(Map.put(attrs, "user_id", user_id))
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
  Returns the list of sensors from given `user_id`.

  ## Examples

      iex> list_sensors(user_id)
      [%Sensor{}, ...]

  """
  def list_sensors(user_id) do
    Repo.all(from s in Sensor, where: s.user_id == ^user_id)
  end

  @doc """
  Returns the list of sensors from given `user_id` and `node_id`.

  ## Examples

      iex> list_sensors_by_node(user_id, node_id)
      [%Sensor{}, ...]

  """
  def list_sensors_by_node(user_id, node_id) do 
    Repo.all(from sensor in Sensor, where: sensor.user_id == ^user_id and sensor.node_id == ^node_id )
  end

  @doc """
  Gets a single sensor from given `user_id`.

  Raises `Ecto.NoResultsError` if the Sensor does not exist.

  ## Examples

      iex> get_sensor!(user_id, 123)
      %Sensor{}

      iex> get_sensor!(user_id, 456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor!(user_id, id) do 
    Repo.one!(from s in Sensor, where: s.user_id == ^user_id and s.id == ^id)
  end

  @doc """
  Gets a single sensor from given `uid` and `user_id`.

  ## Examples

      iex> get_sensor_by_uid(uid)
      %Sensor{}

      iex> get_sensor_by_uid(uid)
      {:error, %Ecto.Changeset{}}

  """
  def get_sensor_by_uid(user_id, uid) do
    Repo.one(from s in Sensor, where: s.user_id == ^user_id and s.sensor_uid == ^uid)
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
  Returns the list of readings from a given `user_id`.

  ## Examples

      iex> list_readings(user_id)
      [%Reading{}, ...]

  """
  def list_readings(user_id) do
    Repo.all(from reading in Reading, where: reading.user_id == ^user_id, order_by: [desc: :inserted_at])
  end


  @doc """
  Returns the list of readings from given `user_id` and `sensor_id`.

  ## Examples

      iex> list_readings_by_sensor(user_id, sensor_id)
      [%Reading{}, ...]

  """
  def list_readings_by_sensor(user_id, sensor_id) do
    Repo.all(from reading in Reading, where: reading.user_id == ^user_id and reading.sensor_id == ^sensor_id, order_by: [desc: :inserted_at])
  end

  @doc """
  Returns the list of readings from given `user_id` and `node_id`.

  ## Examples

      iex> list_readings_by_node(user_id, node_id)
      [%Reading{}, ...]

  """
  def list_readings_by_node(user_id, node_id) do
    query = from reading in Reading, 
      join: sensor in Sensor,
      where: reading.user_id == ^user_id and sensor.id == reading.sensor_id and sensor.node_id == ^node_id,
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
  def get_reading!(user_id, id) do
     Repo.one!(from reading in Reading, where: reading.user_id == ^user_id and reading.id == ^id)
  end

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
    node = get_node_by_uid!(node_uid)

    sensor = get_sensor_by_uid(node.user_id, sensor_uid)
    if sensor == nil do
        sensor_info = %{
            :user_id => node.user_id,
            :node_id => node.id,
            :sensor_uid => sensor_uid,
            :upper => 30,
            :lower => 26,
            :op_mode => "A"
        }

        {:ok, sensor} = create_sensor(sensor_info)
        sensor
    else
        sensor
    end
  end


  def create_reading(node_id, _sensor_id, "id", reading) do
    node = get_node_by_uid!(node_id)
    info = Map.new Enum.map String.split(reading, ";"), fn(item) -> 
        [key, value] = String.split(item, ":")
        {key, value}
    end

    sensor_info = %{
        :lower => 26,
        :op_mode => "A",
        :relay_status => false,
        :sensor_uid => info["id"],
        :upper => 30,
        :user_id => node.user_id,
        :node_id => node.id
    }
    
    create_sensor(sensor_info)
    
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
    else
        {:error, nil}
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

  def trigger_mqtt_commands({:error, changeset}), do: {:error, changeset}
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

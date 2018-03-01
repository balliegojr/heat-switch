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

  def create_reading(node_id, _sensor_id, "id", reading) do
    # register new sensor
    case get_node_by_uid(node_id) do
        {:ok, node} ->
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

  def create_reading(node_id, sensor_id, type, reading) do
    
    sensor_data = case get_sensor_by_uid(sensor_id) do
        sensor -> sensor
        nil -> 
            case get_node_by_uid(node_id) do
                node -> 
                    sensor_info = %{
                        :user_id => node.user_id,
                        :node_id => node.id,
                        :sensor_uid => sensor_id,
                        :upper => 32,
                        :lower => 28,
                        :op_mode => "A"
                    }

                    create_sensor(sensor_info)
                nil -> nil
            end
    end

    case sensor_data do
        sensor ->
            reading_info = %{
                :sensor_uid => sensor_id,
                :type => type,
                :value => reading,
                :user_id => sensor.user_id,
                :sensor_id => sensor.id
            }

            create_reading(reading_info)
        nil -> { :error }
    end


    
  end

  @doc """
  Updates a reading.

  ## Examples

      iex> update_reading(reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    Repo.delete(reading)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{source: %Reading{}}

  """
  def change_reading(%Reading{} = reading) do
    Reading.changeset(reading, %{})
  end
end

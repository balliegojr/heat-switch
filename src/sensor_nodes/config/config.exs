# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :sensor_nodes,
  ecto_repos: [SensorNodes.Repo]

# Configures the endpoint
config :sensor_nodes, SensorNodesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s7/prLUcp7DUbR2wDCiAhgpwa2r5ECqi9U4Prf1nt/Xb8zeCi88rMal6An9T4uIc",
  render_errors: [view: SensorNodesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SensorNodes.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sensor_nodes, SensorNodes.Auth.Guardian,
       issuer: "sensorNodes",
       secret_key: "TY0/ZwAqOcOv81k2ZY8U8Lx6UeLi8k+CTvBXsUgIsn5ZN/me8GvCetmSML+MDkzE"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

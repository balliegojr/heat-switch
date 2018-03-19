defmodule SensorNodes.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :sensor_nodes,
    error_handler: SensorNodes.Auth.ErrorHandler, 
    module: SensorNodes.Auth.Guardian
  
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
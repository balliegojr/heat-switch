defmodule SensorNodesWeb.ControllersHelper do
    alias SensorNodes.Accounts
    alias SensorNodes.Auth.Guardian

    use Phoenix.ConnTest
    
    def get_default_user do
        case Accounts.authenticate_user("user@email.com", "123") do
            {:ok, user} -> user
            {:error, _} ->
                {:ok, user} =  Accounts.create_user(%{email: "user@email.com", username: "user", password: "123", password_confirmation: "123"})
                user
        end
    end


    def authenticate(%{conn: conn}) do
        user = get_default_user()

        # create the token
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        # add authorization header to request
        conn = conn |> put_req_header("authorization", "Bearer #{token}")

        # pass the connection and the user to the test
        {:ok, conn: conn, user: user}
    end
end
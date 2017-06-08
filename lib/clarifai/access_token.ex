defmodule Clarifai.AccessToken do

  require Logger
  require IEx

  alias Clarifai.Client, as: Client
  @token_path "token"

  def request_body do
    %{
      grant_type: "client_credentials",
      client_id: Client.get_clarifai_config(:client_id),
      client_secret: Client.get_clarifai_config(:client_secret)
    }
  end

  def fetch(access_token, true), do: {:ok, access_token}
  def fetch(_, false) do
    Logger.info "Fetching new access_token"
    case Client.post(path: @token_path, body: request_body(), version: :v1, headers: %{}) do
      {:ok, token_json} -> {:ok, build_access_token(token_json)}
      {_, error} -> {:error, error}
    end
  end

  def build_access_token(token_attrs) do
    Logger.info "Building new access_token"
    last_refreshed = DateTime.utc_now() |> DateTime.to_unix()
    expires_in_unix = last_refreshed + token_attrs[:expires_in]

    new_token = %Clarifai.Structs.AccessToken{
      value: token_attrs[:access_token],
      expires_in: expires_in_unix,
      last_refreshed: last_refreshed,
      scope: token_attrs[:scope],
      type: token_attrs[:token_type]
    }

    Client.update(:token, new_token)

    new_token
  end
end

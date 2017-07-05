defmodule Clarifai.AccessToken do
  @moduledoc """
  Handles fetching and formatting the access token.
  A cached access token will be used if one is available.
  """

  require Logger

  alias Clarifai.Client, as: Client
  @token_path "token"

  def fetch(access_token, true) do
    Logger.info "Using cached access token"
    {:ok, access_token}
  end

  def fetch(_, false) do
    case Client.post(path: @token_path, body: request_body(), version: :v2, headers: %{}, options: auth_options()) do
      {:ok, token_json} -> {:ok, build_access_token(token_json)}
      {_, error} -> {:error, error}
    end
  end

  def build_access_token(token_attrs) do
    Logger.info "Building new access token"
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

  defp request_body, do: %{grant_type: "client_credentials"}

  defp auth_options, do: [hackney: [basic_auth: {Client.get_config(:client_id), Client.get_config(:client_secret)}]]
end

defmodule Clarifai.Client do
  @moduledoc """
  Clarifai elixir API client.
  """
  require Logger

  @base_url "https://api.clarifai.com"

  defmodule MissingConfig do
    defexception message: "Missing config value"
  end

  def start_link(_opts) do
    Agent.start_link(fn -> %{token: %Clarifai.Structs.AccessToken{}, models: []} end, name: __MODULE__)
  end

  def base_url, do: @base_url

  def post(path: path, body: body, version: version, headers: headers, options: options) do
    post_url = api_endpoint(path, version)
    encoded_body = Poison.encode!(body)
    headers = headers || json_headers_with_authorization()
    options = options || []

    case HTTPoison.post(post_url, encoded_body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, parse_response(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} -> {:error, format_error(status_code, body)}
      {:error, error} -> {:error, error}
    end
  end

  def get(path: path, version: version, headers: headers) do
    case HTTPoison.get(api_endpoint(path, version), headers || json_headers_with_authorization()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, parse_response(body)}
      {:error, error} -> {:error, error}
    end
  end

  def api_endpoint(path, version \\ :v2), do: "#{@base_url}/#{version}/#{path}"

  def parse_response(json_data) do
    json_data
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def format_error(status_code, json_data) do
    ouput_response = parse_response(json_data)[:outputs] |> List.first

    %{
      http_status_code: status_code,
      status: %{
        code: ouput_response["status"]["code"],
        code_description: ouput_response["status"]["description"],
        details: ouput_response["status"]["details"],
      }
    }
  end

  def get_config(type) when type in [:api_key, :access_token, :client_id, :client_secret, :version] do
    get_system_config(type) ||
      Application.get_env(:clarifai, type) ||
        raise MissingConfig, message: "Missing value for `#{type}`, please define one as an environment variable or within the clarifai configs."
  end

  def get_system_config(type), do: System.get_env("CLARIFAI_#{String.upcase(Atom.to_string(type))}")

  def authorization_headers(access_token, :access_token), do: %{"Authorization": "Bearer #{access_token.value}"}
  def authorization_headers(api_key, :api_key), do: %{"Authorization": "Key #{api_key}"}

  def json_headers_with_authorization do
    case get_config(:api_key) do
      nil -> access_token() |> authorization_headers(:access_token) |> Map.put_new("Content-Type", "application/json")
      api_key -> api_key |> authorization_headers(:api_key) |> Map.put_new("Content-Type", "application/json")
    end
  end

  def access_token do
    cached_access_token = fetch(:token)

    case Clarifai.AccessToken.fetch(cached_access_token, Clarifai.Structs.AccessToken.valid?(cached_access_token)) do
      {:ok, access_token} -> access_token
      {:error, error} -> error
    end
  end

  def fetch(key), do: Agent.get(__MODULE__, fn state -> Map.get(state, key) end)

  def update(key, value), do: Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
end

defmodule Clarifai.Client do
  defmodule MissingConfig do
    defexception message: "Missing config value"
  end

  require Logger
  require IEx

  @base_url "https://api.clarifai.com"

  def start_link(_opts) do
    Agent.start_link(fn -> %{token: %Clarifai.Structs.AccessToken{}, models: []} end, name: __MODULE__)
  end

  def post(path: path, body: body, version: version, headers: headers) do
    Logger.info "Posting to #{api_endpoint(path, version)}"

    case HTTPoison.post(api_endpoint(path, version), {:form, Map.to_list(body)}, headers || json_headers_with_authorization()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, parse_response(body)}
      {:error, error} -> {:error, error}
    end
  end

  def get(path: path, version: version, headers: headers) do
    Logger.info "Requesting from #{api_endpoint(path, version)}"

    case HTTPoison.get(api_endpoint(path, version), headers || json_headers_with_authorization()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, parse_response(body)}
    end
  end

  def api_endpoint(path, version \\ :v2), do: "#{@base_url}/#{version}/#{path}"

  def parse_response(json_data) do
    json_data
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def get_clarifai_config(type) when type in [:access_token, :client_id, :client_secret, :version] do
    System.get_env("CLARIFAI_#{Atom.to_string(type)}") ||
      Application.get_env(:clarifai, type) ||
        raise MissingConfig, message: "Missing value for `#{type}`, please define one as an environment variable or within the clarifai configs."
  end

  def authorization_headers(access_token), do: %{"Authorization": "Bearer #{access_token.value}"}

  def json_headers_with_authorization do
    authorization_headers(access_token()) |> Map.put_new("Content-Type", "application/json")
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

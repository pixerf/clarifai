defmodule ClientTest do
  use ExUnit.Case
  alias Clarifai.Client

  test "it starts with an empty token" do
    assert Client.fetch(:token) == %Clarifai.Structs.AccessToken{}
  end

  describe "Client.access_token/0" do
    setup do
      clear_token()
    end

    test "it raises an error when missing client ID" do
      assert_config_error :client_id, fn -> Client.access_token() end
      assert Client.fetch(:token) == %Clarifai.Structs.AccessToken{}
    end

    test "raises an error when missing client secret" do
      assert_config_error :client_secret, fn -> Client.access_token() end
      assert Client.fetch(:token) == %Clarifai.Structs.AccessToken{}
    end

    test "it stores a new token value" do
      assert Client.fetch(:token).value == nil

      Client.access_token()

      refute Client.fetch(:token).value == nil
    end
  end

  describe "Client.api_endpoint/2" do
    test "returns a full url" do
      path = "test_path"

      assert Client.api_endpoint(path) == "#{Client.base_url}/v2/#{path}"
    end

    test "returns with the correct version number" do
      path = "test_path"
      version = "v1"

      assert Client.api_endpoint(path, version) == "#{Client.base_url}/#{version}/#{path}"
    end
  end

  ## Test Helper ##

  defp assert_config_error(key, fun) do
    system_var = "CLARIFAI_#{String.upcase(Atom.to_string(key))}"
    system_original_value = System.get_env(system_var)
    application_original_value = Application.get_env(:clarifai, key)

    try do
      Application.delete_env(:clarifai, key)
      System.delete_env(system_var)
      assert_raise Clarifai.Client.MissingConfig, "Missing value for `#{key}`, please define one as an environment variable or within the clarifai configs.", fun
    after
      Application.put_env(:clarifai, key, application_original_value)
      System.put_env(system_var, system_original_value)
    end
  end

  defp clear_token do
    Client.update(:token, %Clarifai.Structs.AccessToken{})
  end
end

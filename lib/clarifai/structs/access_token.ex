defmodule Clarifai.Structs.AccessToken do
  defstruct [:value, :last_refreshed, :expires_in, :scope, :type]

  def valid?(nil), do: false
  def valid?(access_token) do
    access_token.value != nil && (DateTime.utc_now |> DateTime.to_unix) <= access_token.expires_in - 5
  end
end

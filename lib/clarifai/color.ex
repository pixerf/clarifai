defmodule Clarifai.Color do
  @tag_path "color"

  def get(image_urls) when is_binary(image_urls), do: fetch_colors([image_urls])
  def get(image_urls) when is_list(image_urls), do: fetch_colors(image_urls)

  defp fetch_colors(image_urls) do
    case Clarifai.Client.post(@tag_path, %{url: image_urls}) do
      {:ok, parsed_json} -> {:ok, build_colors(parsed_json)}
      {:error, error} -> {:error, error}
    end
  end

  defp build_colors(color_response) do
  end
end

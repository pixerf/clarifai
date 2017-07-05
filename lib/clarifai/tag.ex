defmodule Clarifai.Tag do
  @moduledoc """
  Handles requesting and formatting data for a single image and model.
  """

  require Logger

  @tag_path "models"

  def fetch_tags(model_name, image_url) do
    model = Clarifai.Model.find_by(:name, model_name)

    case Clarifai.Client.post(path: "#{@tag_path}/#{model.id}/outputs", body: build_body([image_url]), version: :v2, headers: nil, options: nil) do
      {:ok, parsed_json} -> {:ok, build_tags(model, parsed_json)}
      {:error, error} -> {:error, error}
    end
  end

  defp build_tags(model, tags_response) do
    for ouput <- tags_response[:outputs], do: build_output(model, ouput)
  end

  defp build_output(model, output) do
    %{
      data: %{id: output["input"]["id"], model_name: model.name, url: output["input"]["data"]["image"]["url"]},
      tags: build_tags_by_type(model.name, output["data"])
    }
  end

  defp build_tags_by_type(_, data) when data == %{}, do: []
  defp build_tags_by_type("celeb-v1.3", %{"regions" => data}), do: Clarifai.Structs.LayeredTag.build_from_response(:identity, data)
  defp build_tags_by_type("color", %{"colors" => data}), do: for color_response <- data, do: Clarifai.Structs.ColorTag.build_from_response(color_response)
  defp build_tags_by_type("focus", %{"focus" => data}), do: Clarifai.Structs.FocusTag.build_from_response(data)
  defp build_tags_by_type("logo", %{"regions" => data}), do: Clarifai.Structs.LayeredTag.build_from_response(:detection, data)
  defp build_tags_by_type(_, %{"concepts" => data}), do: for response <- data, do: Clarifai.Structs.Tag.build_from_response(response)

  defp build_body(image_urls) do
    inputs = for image_url <- image_urls, do: %{"data": %{"image": %{"url": image_url}}}

    %{inputs: inputs}
  end
end

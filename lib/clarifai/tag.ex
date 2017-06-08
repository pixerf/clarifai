defmodule Clarifai.Tag do
  require IEx
  require Logger

  @tag_path "tag"

  def get(image_urls) when is_binary(image_urls), do: fetch_tags([image_urls])
  def get(image_urls) when is_list(image_urls), do: fetch_tags(image_urls)

  defp fetch_tags(image_urls) do
    case Clarifai.Client.post(path: @tag_path, body: build_body(image_urls), version: :v2, headers: nil) do
      {:ok, parsed_json} -> {:ok, build_tags(parsed_json)}
      {:error, error} -> {:error, error}
    end
  end

  defp build_tags(tags_response) do
    for result <- tags_response[:results], do: build_tag(result)
  end

  defp build_tag(tag_response) do
    %Clarifai.Structs.Tag{
      url: tag_response["url"],
      docid: tag_response["docid"],
      docid_str: tag_response["docid_str"],
      classes: tag_response["result"]["tag"]["classes"],
      concept_ids: tag_response["result"]["tag"]["concept_ids"],
      probs: tag_response["result"]["tag"]["probs"]
    }
  end

  defp build_body(image_urls) do
    inputs = for image_url <- image_urls, do: %{ "data": %{ "image": %{ "url": image_url } } }

    %{inputs: inputs}
  end
end

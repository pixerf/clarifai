defmodule Clarifai.Structs.Tag do
  @moduledoc """
  Main tag used for most models. Contains the name, concept ID and confidence for a given tag.
  """

  defstruct [:name, :concept_id, :confidence]

  def build_from_response(tag_response) do
    %Clarifai.Structs.Tag{
      concept_id: tag_response["id"],
      name: tag_response["name"],
      confidence: tag_response["value"]
    }
  end
end

defmodule Clarifai.Structs.ColorTag do
  @moduledoc """
  Color tag used for the color model. Contains the hex value, density value, and name of the color.

  Definitions:

  hex: Hex color code.
  density value: Decimal value describing percent of image represented by the color.
  """

  defstruct [:hex, :value, :name]

  def build_from_response(color_response) do
    %Clarifai.Structs.ColorTag{
      hex: color_response["w3c"]["hex"],
      value: color_response["value"],
      name: color_response["w3c"]["name"]
    }
  end
end

defmodule Clarifai.Structs.FocusTag do
  @moduledoc """
  Focus tag used for the focus model. Contains the level of focus value.
  """

  defstruct [:value]

  def build_from_response(focus_response) do
    [%Clarifai.Structs.FocusTag{value: focus_response["value"]}]
  end
end

defmodule Clarifai.Structs.LayeredTag do
  @moduledoc """
  Layered tag used for the models that contain nested attributes specific to a given model.
  Should not be used as a struct but as builder for Tags.
  """

  def build_from_response(model_type, detection_responses) do
    attrs_list = case model_type do
      :identity -> ["data", "face", "concepts"]
      :detection -> ["data", "concepts"]
    end

    dig_and_build_layered_tags(attrs_list, detection_responses)
  end

  defp dig_and_build_layered_tags(attrs_list, detection_responses) do
    List.flatten(
      Enum.map(
        detection_responses,
        fn(detection_response) ->
          for data <- get_in(detection_response, attrs_list), do: Clarifai.Structs.Tag.build_from_response(data)
        end
      )
    )
  end
end

defmodule Clarifai.Structs.TagsByModel do
  @moduledoc """
  Tags grouped by model.
  """

  defstruct [:model, tags: [%Clarifai.Structs.Tag{}]]
end

defmodule Clarifai.Structs.Prediction do
  @moduledoc """
  Prediction data for a single image. A prediction may have many tags grouped by model.
  """

  defstruct [:status, :image_url, :errors, tags_by_model: [%Clarifai.Structs.TagsByModel{}], ]
end

defmodule Clarifai.Structs.Response do
  @moduledoc """
  The main returned response that may contain many predictions.
  """

  defstruct [predictions: [%Clarifai.Structs.Prediction{}]]

  def build(predictions, response \\ %{}, errors \\ [])

  def build([], response, errors) do
    predictions = for {image_url, tags_by_model} <- response, do: %Clarifai.Structs.Prediction{status: :ok, image_url: image_url, tags_by_model: tags_by_model, errors: errors}

    %Clarifai.Structs.Response{predictions: predictions}
  end

  def build([{:ok, outputs} | remaining_predictions], response, errors) do
    output = List.first(outputs)

    {_status, updated_response} = Map.get_and_update(
      response,
      output.data.url,
      fn current_value ->
        {current_value, (current_value || []) ++ [%Clarifai.Structs.TagsByModel{model: output.data.model_name, tags: output.tags}]}
      end
    )

    build(remaining_predictions, updated_response, errors)
  end

  def build([{:error, outputs} | remaining_predictions], response, errors) do
    build(remaining_predictions, response, errors ++ [outputs])
  end
end

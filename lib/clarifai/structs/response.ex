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
  defstruct [:status, :image_url, tags_by_model: [%Clarifai.Structs.TagsByModel{}]]
end

defmodule Clarifai.Structs.Response do
  @moduledoc """
  The main returned response that may contain many predictions.
  """

  defstruct [predictions: [%Clarifai.Structs.Prediction{}]]

  def build(predictions, response \\ %{})

  def build([], response) do
    predictions = for {image_url, tags_by_model} <- response, do: %Clarifai.Structs.Prediction{status: :ok, image_url: image_url, tags_by_model: tags_by_model}

    %Clarifai.Structs.Response{predictions: predictions}
  end

  def build([first_prediction | remaining_predictions], response) do
    {_status, [h | _t]} = first_prediction

    {_status, updated_response} = Map.get_and_update(
      response,
      h.data.url,
      fn current_value ->
        {current_value, (current_value || []) ++ [%Clarifai.Structs.TagsByModel{model: h.data.model_name, tags: h.tags}]}
      end
    )

    build(remaining_predictions, updated_response)
  end
end

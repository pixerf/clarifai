defmodule Clarifai do
  @moduledoc """
  Access point for all the methods that the user _should_ need.
  """

  @doc """
  Returns predictions for the given urls.

  N.B. An API request is made for each url for each model due to the way Clarifai's API operates.
  Eg. Predictions for 15 urls across 3 models will result in a total of 45 API calls.
  If there is a better way to do this, feel free to open up an issue @ https://github.com/ChanChar/clarifai or submit a PR.

  Returns a `Clarifai.Structs.Response` containing the predictions.
  Each image has one prediction and each prediction can have many tags grouped by model.
  """
  @spec predict(nonempty_list(binary), list(binary)) :: %Clarifai.Structs.Response{}
  def predict(urls, models \\ ["general-v1.3"]) do
    Clarifai.Structs.Response.build(for model <- models, url <- urls, do: Clarifai.Tag.fetch_tags(model, url))
  end

  defdelegate models, to: Clarifai.Model, as: :index
  defdelegate model_names, to: Clarifai.Model, as: :index_names
  defdelegate refresh_models, to: Clarifai.Model, as: :get_index
end

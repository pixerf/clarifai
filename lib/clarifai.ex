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

  ## Examples

      iex> Clarifai.predict(["https://unsplash.it/5092/3395?image=1062"], ["colors", "general-v1.3"])

      %Clarifai.Structs.Response{
        predictions: [
          %Clarifai.Structs.Prediction{
            image_url: "https://unsplash.it/5092/3395?image=1062",
            status: :ok,
            tags_by_model: [
              %Clarifai.Structs.TagsByModel{
                model: "color",
                tags: [
                  %Clarifai.Structs.ColorTag{hex: "#696969", name: "DimGray", value: 0.20425},
                  %Clarifai.Structs.ColorTag{hex: "#b0c4de", name: "LightSteelBlue", value: 0.40675},
                  %Clarifai.Structs.ColorTag{hex: "#808080", name: "Gray", value: 0.389}
                ]
              },
              %Clarifai.Structs.TagsByModel{
                model: "general-v1.3",
                tags: [
                  %Clarifai.Structs.Tag{concept_id: "ai_B2TBwp8F", confidence: 0.9732083, name: "bed"},
                  %Clarifai.Structs.Tag{concept_id: "ai_TJ9wFfK5", confidence: 0.96748126, name: "portrait"},
                  %Clarifai.Structs.Tag{concept_id: "ai_CnBc0kwc", confidence: 0.94953597, name: "sleep"},
                  %Clarifai.Structs.Tag{concept_id: "ai_4CRlSvbV", confidence: 0.9400542, name: "cute"},
                  %Clarifai.Structs.Tag{concept_id: "ai_bJt1PfQ5", confidence: 0.91432786, name: "bedroom"},
                  %Clarifai.Structs.Tag{concept_id: "ai_j09mzT6j", confidence: 0.9100505, name: "family"},
                  %Clarifai.Structs.Tag{concept_id: "ai_8S2Vq3cR", confidence: 0.89849144, name: "dog"},
                  ...,
                  %Clarifai.Structs.Tag{concept_id: "ai_SzsXMB1w", confidence: 0.7452092, name: "animal"}
                ]
              }
            ]
          }
        ]
      }

  """
  @spec predict(nonempty_list(binary), list(binary)) :: %Clarifai.Structs.Response{}
  def predict(urls, models \\ ["general-v1.3"]) do
    Clarifai.Structs.Response.build(for model <- models, url <- urls, do: Clarifai.Tag.fetch_tags(model, url))
  end

  defdelegate models, to: Clarifai.Model, as: :index
  defdelegate model_names, to: Clarifai.Model, as: :index_names
  defdelegate refresh_models, to: Clarifai.Model, as: :get_index
end

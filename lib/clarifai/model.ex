defmodule Clarifai.Model do
  @model_path "models"

  alias Clarifai.Client, as: Client

  def available_models do
    case Client.fetch(:models) do
      nil -> fetch_models()
      models -> models
    end
  end

  def fetch_models do
    case Clarifai.Client.get(path: @model_path, version: :v2, headers: nil) do
      {:ok, parsed_json} -> {:ok, build_models(parsed_json)}
      {:error, error} -> {:error, error}
    end
  end

  def build_models(models_json) do
    status = models_json[:status]
    models = for model_attr <- models_json[:models], do: build_model(model_attr)

    Client.update(:models, models)

    models
  end

  def build_model(model_attr) do
    model_attr = model_attr |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)

    %Clarifai.Structs.Model{
      app_id: model_attr[:app_id],
      created_at: model_attr[:created_at],
      id: model_attr[:id],
      version: model_attr[:model_version],
      name: model_attr[:name],
      output_info: model_attr[:output_info]
    }
  end
end

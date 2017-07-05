defmodule Clarifai.Model do
  @moduledoc """
  Handles fetching and formatting Clarifai models.
  """

  @model_path "models"
  @unsupported_types ["facedetect", "embed"]

  require IEx

  alias Clarifai.Client, as: Client

  def index do
    case Client.fetch(:models) do
      [] -> get_index()
      models -> {:ok, models}
    end
  end

  def index_names do
    {:ok, models} = index()

    {:ok, Enum.filter_map(models, fn(model) -> !Enum.member?(@unsupported_types, model.output_info["type_ext"]) end, &(Map.get(&1, :name)))}
  end

  def get_index do
    case Clarifai.Client.get(path: @model_path, version: :v2, headers: nil) do
      {:ok, parsed_json} -> {:ok, build_models(parsed_json)}
      {:error, error} -> {:error, error}
    end
  end

  def find_by(attribute_type, attribute) do
    {:ok, models} = index()

    Enum.find(
      models, fn(model) -> attribute == Map.get(model, attribute_type) && model.output_info["type"] != "embed" end
    )
  end

  def build_models(models_json) do
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

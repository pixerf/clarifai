defmodule Clarifai.Structs.Model do
  @moduledoc """
  Structure for a Clarifai model.
  """

  @type t :: %Clarifai.Structs.Model{app_id: binary, created_at: binary, id: binary, name: binary, output_info: any, version: any}
  defstruct [:app_id, :id, :version, :name, :output_info, :created_at]
end

defmodule Clarifai.Structs.Models do
  @moduledoc """
  Structure for a list of models.
  """

  @type t :: %Clarifai.Structs.Models{models: [%Clarifai.Structs.Model{}]}
  defstruct [models: [%Clarifai.Structs.Model{}]]
end

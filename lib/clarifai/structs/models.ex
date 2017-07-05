defmodule Clarifai.Structs.Model do
  @moduledoc """
  Structure for a Clarifai model.
  """

  defstruct [:app_id, :id, :version, :name, :output_info, :created_at]
end

defmodule Clarifai.Structs.Models do
  @moduledoc """
  Structure for a list of models.
  """

  defstruct [models: [%Clarifai.Structs.Model{}]]
end

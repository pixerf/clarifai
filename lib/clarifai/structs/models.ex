defmodule Clarifai.Structs.Model do
  defstruct [:app_id, :id, :version, :name, :output_info, :created_at]
end

defmodule Clarifai.Structs.Models do
  defstruct [models: [%Clarifai.Structs.Model{}]]
end

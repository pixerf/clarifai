defmodule Clarifai.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Clarifai.Client, [Clarifai.Client])]
    opts = [strategy: :one_for_one, name: Clarifai.Supervisor]

    Supervisor.start_link(children, opts)
  end
end

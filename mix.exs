defmodule Clarifai.Mixfile do
  use Mix.Project

  def project do
    [app: :clarifai,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :httpoison],
     mod: {Clarifai.Application, []}]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.0"}
    ]
  end
end

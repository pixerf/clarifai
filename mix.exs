defmodule Clarifai.Mixfile do
  use Mix.Project

  def project do
    [
      app: :clarifai,
      version: "0.2.1",
      elixir: "~> 1.4",
      preferred_cli_env: [espec: :test],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Clarifai",
      source_url: "https://github.com/ChanChar/clarifai",
      docs: [
        main: "Clarifai",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Clarifai.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.0"}
    ]
  end

  defp description do
    "Elixir API client for Clarifai."
  end

  defp package do
    [
      name: :clarifai,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Charles C. Lee"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ChanChar/clarifai"}
    ]
  end
end

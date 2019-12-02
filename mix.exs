defmodule AoC.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :advent_of_code,
      version: "2019.0.1",
      elixir: "~> 1.9",
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [espec: :test],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      test: ["format", "credo --strict", "dialyzer", "espec"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      {:espec, "~> 1.7", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end

defmodule AoC.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :advent_of_code,
      version: "2019.0.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:espec, "~> 1.7", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end

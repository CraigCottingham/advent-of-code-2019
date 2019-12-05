defmodule AoC.Intcode.Memory do
  @moduledoc false

  def load_file(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule AoC.Intcode.Memory do
  @moduledoc false

  def load_from_file(filename) do
    filename
    |> File.stream!()
    |> load_from_stream()
  end

  def load_from_stream(stream) do
    stream
    |> Enum.map(&String.trim/1)
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end
end

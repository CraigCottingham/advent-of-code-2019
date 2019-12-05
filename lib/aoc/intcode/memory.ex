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

  def set_noun(mem, nil), do: mem
  def set_noun(mem, noun), do: List.replace_at(mem, 1, noun)

  def set_verb(mem, nil), do: mem
  def set_verb(mem, verb), do: List.replace_at(mem, 2, verb)
end

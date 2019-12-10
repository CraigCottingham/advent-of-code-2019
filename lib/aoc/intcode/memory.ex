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

  def pad(memory, current_bound, to_address) when current_bound > to_address, do: memory

  def pad(memory, current_bound, to_address),
    do: List.flatten([memory | List.duplicate(0, to_address - current_bound + 1)])

  def read(memory, address) do
    if address >= Enum.count(memory) do
      0
    else
      Enum.at(memory, address)
    end
  end

  def write(memory, address, value) do
    memory
    |> pad(Enum.count(memory), address)
    |> List.replace_at(address, value)
  end
end

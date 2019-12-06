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

  def read(memory, address) do
    if address >= Enum.count(memory) do
      raise "memory read out of bounds (address = #{address}): #{inspect(memory)}"
    else
      Enum.at(memory, address)
    end
  end

  def write(memory, address, value) do
    if address >= Enum.count(memory) do
      raise "memory write out of bounds (address = #{address}): #{inspect(memory)}"
    else
      List.replace_at(memory, address, value)
    end
  end
end

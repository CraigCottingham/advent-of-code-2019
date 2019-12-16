defmodule AoC.Day16 do
  @moduledoc false

  def part_1 do
    "data/day16-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.join("")
    |> split_signal()
    |> checksum(100)
  end

  def part_2 do
  end

  def checksum(input, n) do
    1..n
    |> Enum.reduce(input, fn _, signal -> dither_signal(signal) end)
    |> Enum.take(8)
    |> Enum.map(fn digit -> "#{digit}" end)
    |> Enum.join()
    |> String.to_integer()
  end

  def dither_signal(input) do
    {dithered, _} =
      Enum.map_reduce(input, 1, fn _, index -> {dither_with_offset(input, index), index + 1} end)

    dithered
  end

  def dither_with_offset(input, offset) do
    offset
    |> get_dither_pattern()
    |> Enum.zip(input)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + a * b end)
    |> abs()
    |> Integer.mod(10)
  end

  def get_dither_pattern(n) when n in [0, 1] do
    [0, 1, 0, -1]
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  def get_dither_pattern(n) do
    [0, 1, 0, -1]
    |> Enum.map(&List.duplicate(&1, n))
    |> List.flatten()
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  def split_signal(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

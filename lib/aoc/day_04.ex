defmodule AoC.Day04 do
  @moduledoc false

  def part_1 do
    236_491..713_787
    |> Enum.filter(&has_consecutive_digits?/1)
    |> Enum.filter(&is_monotonically_increasing?/1)
    |> Enum.count()
  end

  def part_2 do
    236_491..713_787
    |> Enum.filter(&has_consecutive_digits?/1)
    |> Enum.filter(&is_monotonically_increasing?/1)
    |> Enum.filter(&has_small_consecutive_block?/1)
    |> Enum.count()
  end

  def has_consecutive_digits?(number) do
    Regex.match?(~r/(\d)\1/, Integer.to_string(number))
  end

  def has_small_consecutive_block?(number) do
    number
    |> Integer.to_string()
    |> String.split("", trim: true)
    |> Enum.chunk_by(& &1)
    |> Enum.any?(&(Enum.count(&1) == 2))
  end

  def is_monotonically_increasing?(number) do
    number
    |> Integer.to_string()
    |> String.split("", trim: true)
    |> Enum.reduce_while("0", fn
      digit, acc when digit >= acc -> {:cont, digit}
      _, _ -> {:halt, nil}
    end)
  end
end

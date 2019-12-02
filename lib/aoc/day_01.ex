defmodule AoC.Day01 do
  @moduledoc false

  def part_1 do
    File.stream!("data/day01-input.txt")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&calculate_fuel/1)
    |> Enum.reduce(0, &(&1 + &2))
  end

  # def part_2 do
  #   File.stream!("data/day01-input.txt")
  #   |> Enum.map(&String.trim/1)
  #   |> Enum.map(&String.to_integer/1)
  #   |> Enum.reduce([], fn delta, acc -> [acc, delta] end)
  #   |> List.flatten
  #   |> Stream.cycle
  #   |> Enum.reduce_while({0, MapSet.new([0])}, &calc_new_frequency/2)
  #   |> elem(0)
  # end

  def calculate_fuel(mass), do: Integer.floor_div(mass, 3) - 2
end

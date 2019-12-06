defmodule AoC.Day06 do
  @moduledoc false

  def part_1 do
    "data/day06-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%{}, fn line, acc ->
      {parent, child} = split_orbit_string(line)
      add_orbit(acc, parent, child)
    end)
    |> total_orbits()
  end

  def part_2 do
  end

  def add_orbit(ds, parent, child) do
    ds
    |> Map.update(child, [], fn value -> value end)
    |> Map.update(parent, [child], fn value -> [child | value] end)
  end

  def split_orbit_string(str), do: List.to_tuple(String.split(str, ")"))

  def total_orbits(ds) do
    ds
    |> Map.keys()
    |> Enum.reduce(0, &(&2 + tree_depth(ds, &1)))
  end

  def tree_depth(ds, body) do
    case Enum.find(ds, fn {_parent, children} ->
           Enum.any?(children, &(&1 == body))
         end) do
      {parent, _children} ->
        1 + tree_depth(ds, parent)

      _ ->
        0
    end
  end
end

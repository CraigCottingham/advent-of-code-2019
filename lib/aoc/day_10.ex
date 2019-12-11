defmodule AoC.Day10 do
  @moduledoc false

  def part_1 do
    "data/day10-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> AoC.Day10.max_detected()
  end

  def part_2 do
  end

  def angle({a_row, a_col}, {b_row, b_col}) when a_row == b_row and a_col == b_col,
    do: raise("cannot find angle to itself")

  def angle({a_row, a_col}, {b_row, b_col}) when a_row < b_row and a_col < b_col,
    do: Math.atan((a_row - b_row) / (b_col - a_col)) + Math.pi()

  def angle({a_row, a_col}, {b_row, b_col}) when a_row < b_row and a_col == b_col,
    do: Math.pi()

  def angle({a_row, a_col}, {b_row, b_col}) when a_row < b_row and a_col > b_col,
    do: Math.atan((a_row - b_row) / (b_col - a_col)) + Math.pi()

  def angle({a_row, a_col}, {b_row, b_col}) when a_row == b_row and a_col < b_col,
    do: Math.pi() / 2

  def angle({a_row, a_col}, {b_row, b_col}) when a_row == b_row and a_col > b_col,
    do: Math.pi() * 3 / 2

  def angle({a_row, a_col}, {b_row, b_col}) when a_row > b_row and a_col < b_col,
    do: Math.atan((a_row - b_row) / (b_col - a_col))

  def angle({a_row, a_col}, {b_row, b_col}) when a_row > b_row and a_col == b_col,
    do: 0

  def angle({a_row, a_col}, {b_row, b_col}) when a_row > b_row and a_col > b_col,
    do: Math.atan((a_row - b_row) / (b_col - a_col)) + Math.pi() * 2

  def detected_count(a, bs) do
    a
    |> position_angles(bs)
    |> Enum.group_by(fn {_, angle} -> angle end)
    |> map_size()
  end

  def filter(matrix, fun) do
    matrix
    |> Max.map(fn index, value ->
      position = Max.index_to_position(matrix, index)
      {position, value}
    end)
    |> Enum.filter(fun)
    |> Enum.map(fn {position, _} -> position end)
  end

  def map_data_to_matrix(data) do
    data
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(
      &Enum.map(&1, fn
        "#" -> 1
        _ -> 0
      end)
    )
    |> Max.from_list_of_lists()
  end

  def max_detected(map_data) do
    positions =
      map_data
      |> map_data_to_matrix()
      |> filter(fn {_, value} -> value == 1 end)

    positions
    |> Enum.map(fn a ->
      bs = List.delete(positions, a)
      {a, AoC.Day10.detected_count(a, bs)}
    end)
    |> Enum.max_by(fn {_, count} -> count end)
    |> elem(1)
  end

  def position_angles(a, bs), do: Enum.map(bs, fn b -> {b, angle(a, b)} end)
end

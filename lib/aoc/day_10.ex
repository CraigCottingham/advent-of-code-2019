defmodule AoC.Day10 do
  @moduledoc false

  def part_1 do
    "data/day10-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> AoC.Day10.max_detected()
    |> elem(1)
  end

  def part_2 do
    map_data =
      "data/day10-input.txt"
      |> File.stream!()
      |> Enum.map(&String.trim/1)

    {base, _} = AoC.Day10.max_detected(map_data)

    AoC.Day10.zap_asteroids(map_data, base)
    |> Enum.at(199)
    |> (fn {x, y} -> x * 100 + y end).()
  end

  def angle({a_col, a_row}, {b_col, b_row}) when a_row == b_row and a_col == b_col,
    do: raise("cannot find angle to itself")

  def angle({a_col, a_row}, {b_col, b_row}) when a_row > b_row and a_col == b_col,
    do: 0

  def angle({a_col, a_row}, {b_col, b_row}) when a_row > b_row and a_col < b_col,
    do: Math.atan((b_col - a_col) / (a_row - b_row))

  def angle({a_col, a_row}, {b_col, b_row}) when a_row == b_row and a_col < b_col,
    do: Math.pi() / 2

  def angle({a_col, a_row}, {b_col, b_row}) when a_row < b_row and a_col < b_col,
    do: Math.atan((b_row - a_row) / (b_col - a_col)) + Math.pi() / 2

  def angle({a_col, a_row}, {b_col, b_row}) when a_row < b_row and a_col == b_col,
    do: Math.pi()

  def angle({a_col, a_row}, {b_col, b_row}) when a_row < b_row and a_col > b_col,
    do: Math.atan((a_col - b_col) / (b_row - a_row)) + Math.pi()

  def angle({a_col, a_row}, {b_col, b_row}) when a_row == b_row and a_col > b_col,
    do: Math.pi() * 3 / 2

  def angle({a_col, a_row}, {b_col, b_row}) when a_row > b_row and a_col > b_col,
    do: Math.atan((a_row - b_row) / (a_col - b_col)) + Math.pi() * 3 / 2

  def detected_count(a, bs) do
    a
    |> group_by_angle(bs)
    |> map_size()
  end

  def distance({a_row, a_col}, {b_row, b_col}),
    do: Math.sqrt(Math.pow(b_row - a_row, 2) + Math.pow(b_col - a_col, 2))

  def filter(matrix, fun) do
    matrix
    |> Max.map(fn index, value ->
      {row, col} = Max.index_to_position(matrix, index)
      {{col, row}, value}
    end)
    |> Enum.filter(fun)
    |> Enum.map(fn {position, _} -> position end)
  end

  def group_by_angle(a, bs) do
    a
    |> position_angles(bs)
    |> Enum.group_by(fn {_, angle} -> angle end)
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
  end

  def position_angles(a, bs), do: Enum.map(bs, fn b -> {b, angle(a, b)} end)

  def zap([], zapped_order), do: Enum.reverse(zapped_order)
  def zap([{_, []} | angle_tail], zapped_order), do: zap(angle_tail, zapped_order)

  def zap([{angle, [{position, _} | range_tail]} | angle_tail], zapped_order) do
    [angle_tail, {angle, range_tail}]
    |> List.flatten()
    |> zap([position | zapped_order])
  end

  def zap_asteroids(map_data, base) do
    positions =
      map_data
      |> map_data_to_matrix()
      |> filter(fn {_, value} -> value == 1 end)

    others = List.delete(positions, base)

    group_by_angle(base, others)
    |> Map.to_list()
    |> Enum.sort_by(fn {angle, _} -> angle end)
    |> Enum.map(fn {angle, positions} ->
      {angle, Enum.sort_by(positions, fn {position, _} -> distance(base, position) end)}
    end)
    |> zap([])
  end
end

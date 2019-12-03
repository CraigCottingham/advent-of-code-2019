defmodule AoC.Day03 do
  @moduledoc ~S"""
  https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
  """

  def part_1 do
    "data/day03-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    end)
    |> closest_intersection()
    |> manhattan_distance({0, 0})
  end

  # def part_2 do
  #   "data/day03-input.txt"
  #   |> load_program()
  #   |> run_intcode_program({12, 2})
  #   |> Enum.at(0)
  # end

  defp all_intersections([path1, path2]) do
    for s1 <- path_to_segments(path1, {0, 0}, []), s2 <- path_to_segments(path2, {0, 0}, []) do
      {s1, s2, intersect?(s1, s2)}
    end
    |> Enum.filter(fn {_, _, intersect} -> intersect end)
    |> Enum.map(fn {s1, s2, _} -> AoC.Day03.intersection(s1, s2) end)
    |> Enum.reject(fn p -> p == {0, 0} end)
  end

  def closest_intersection([path1, path2]) do
    all_intersections([path1, path2])
    |> Enum.min_by(fn p -> AoC.Day03.manhattan_distance({0, 0}, p) end)
  end

  def intersect?({p1, q1}, {p2, q2}) do
    o1 = orientation(p1, q1, p2)
    o2 = orientation(p1, q1, q2)
    o3 = orientation(p2, q2, p1)
    o4 = orientation(p2, q2, q1)

    if o1 != o2 && o3 != o4 do
      true
    else
      # // p1, q1 and p2 are colinear and p2 lies on segment p1q1
      # if (o1 == 0 && onSegment(p1, p2, q1)) return true;
      #
      # // p1, q1 and q2 are colinear and q2 lies on segment p1q1
      # if (o2 == 0 && onSegment(p1, q2, q1)) return true;
      #
      # // p2, q2 and p1 are colinear and p1 lies on segment p2q2
      # if (o3 == 0 && onSegment(p2, p1, q2)) return true;
      #
      #  // p2, q2 and q1 are colinear and q1 lies on segment p2q2
      # if (o4 == 0 && onSegment(p2, q1, q2)) return true;

      false
    end
  end

  def intersection({{p1x, _p1y}, {q1x, _q1y}}, {{_p2x, p2y}, {_q2x, q2y}})
      when p1x == q1x and p2y == q2y,
      do: {p1x, p2y}

  def intersection({{_p1x, p1y}, {_q1x, q1y}}, {{p2x, _p2y}, {q2x, _q2y}})
      when p2x == q2x and p1y == q1y,
      do: {p2x, p1y}

  def manhattan_distance({px, py}, {qx, qy}), do: abs(qx - px) + abs(qy - py)

  def orientation({px, py}, {qx, qy}, {rx, ry}) do
    case (qy - py) * (rx - qx) - (qx - px) * (ry - qy) do
      0 -> :colinear
      val when val > 0 -> :cw
      _ -> :ccw
    end
  end

  def path_to_segments(path, last_point, segments \\ [])

  def path_to_segments([], _, segments), do: Enum.reverse(segments)

  def path_to_segments([vector | tail], {last_x, last_y} = last_point, segments) do
    next_point =
      case Regex.named_captures(~r/(?<direction>[DLRU])(?<distance>\d+)/, vector) do
        %{"direction" => "D", "distance" => distance} ->
          {last_x, last_y - String.to_integer(distance)}

        %{"direction" => "L", "distance" => distance} ->
          {last_x - String.to_integer(distance), last_y}

        %{"direction" => "R", "distance" => distance} ->
          {last_x + String.to_integer(distance), last_y}

        %{"direction" => "U", "distance" => distance} ->
          {last_x, last_y + String.to_integer(distance)}
      end

    path_to_segments(tail, next_point, [{last_point, next_point} | segments])
  end

  def path_length_to_point(path, point, length_so_far \\ 0)

  def path_length_to_point([], _, length_so_far), do: length_so_far

  def path_length_to_point([{{px, py}, {qx, qy}} | tail], {rx, ry} = point, length_so_far) do
    cond do
      py == qy && py == ry && Enum.member?(px..qx, rx) ->
        length_so_far + abs(rx - px)

      px == qx && px == rx && Enum.member?(py..qy, ry) ->
        length_so_far + abs(ry - py)

      true ->
        path_length_to_point(tail, point, length_so_far + abs(qx - px) + abs(qy - py))
    end
  end
end

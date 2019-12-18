defmodule AoC.Day17 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory, VacuumRobot}

  def part_1 do
    "data/day17-input.txt"
    |> Memory.load_from_file()
    |> generate_view()
    |> intersections()
    |> Enum.map(&alignment_parameter/1)
    |> Enum.sum()
  end

  def part_2 do
  end

  def alignment_parameter({row, col}), do: row * col

  def extract_horizontal_segments(view) do
    view
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, row}, acc ->
      [acc, {row, Regex.scan(~r/[#^v<>]+/, line, return: :index)}]
    end)
    |> List.flatten()
    |> Enum.map(fn {row, segments} -> {row, List.flatten(segments)} end)
    |> Enum.map(fn {row, segments} ->
      {row, Enum.reject(segments, fn {_, length} -> length < 2 end)}
    end)
    |> Enum.reject(fn {_, segments} -> Enum.empty?(segments) end)
    |> Enum.map(fn {row, segments} ->
      Enum.reduce(segments, [], fn {start, length}, acc ->
        [{{row, start}, {row, start + length - 1}}] ++ acc
      end)
    end)
    |> List.flatten()
  end

  def extract_vertical_segments(view) do
    view
    |> flip_diagonal()
    |> extract_horizontal_segments()

    # [{{2, 0}, {4, 0}}, {{0, 2}, {6, 2}}, {{2, 6}, {6, 6}}, {{2, 10}, {6, 10}}, {{2, 12}, {4, 12}}]
    |> Enum.map(fn {{r1, c1}, {r2, c2}} -> {{c1, r1}, {c2, r2}} end)
  end

  def flip_diagonal(view) do
    # rows = Enum.count(view)

    view
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  def generate_view(memory) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])
    robot = Task.async(VacuumRobot, :initialize, [%{cpu: cpu}])

    cpu_output_fn = fn value -> send(robot.pid, {:pixel, value}) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(robot.pid, :start)

    {:halt, _} = Task.await(cpu, :infinity)
    send(robot.pid, :term)
    {:halt, state} = Task.await(robot, :infinity)

    state
    |> Map.get(:view)
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&IO.chardata_to_string/1)
  end

  def intersections(view) do
    horizontal = extract_horizontal_segments(view)
    vertical = extract_vertical_segments(view)

    for h <- horizontal, v <- vertical do
      {h, v}
    end
    |> Enum.filter(fn {h, v} -> AoC.Day03.intersect?(h, v) end)
    |> Enum.reject(fn {{p1, _}, {p2, _}} -> p1 == p2 end)
    |> Enum.reject(fn {{_, p1}, {p2, _}} -> p1 == p2 end)
    |> Enum.reject(fn {{p1, _}, {_, p2}} -> p1 == p2 end)
    |> Enum.reject(fn {{_, p1}, {_, p2}} -> p1 == p2 end)
    |> Enum.map(fn {{{row, _}, _}, {{_, col}, _}} -> {row, col} end)
  end
end

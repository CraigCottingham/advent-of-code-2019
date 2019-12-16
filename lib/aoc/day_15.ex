defmodule AoC.Day15 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory, RepairDroid}

  def part_1 do
    %{map: map, target_position: target_position} =
      "data/day15-input.txt"
      |> Memory.load_from_file()
      |> find_target()

    shortest_path = Graph.get_shortest_path(map, {0, 0}, target_position)
    Enum.count(shortest_path) - 1
  end

  def part_2 do
    %{map: map, target_position: target_position} =
      "data/day15-input.txt"
      |> Memory.load_from_file()
      |> find_target()

    {_, greatest_path_length} =
      map
      |> Graph.vertices()
      |> List.delete(target_position)
      |> Enum.map(fn position ->
        shortest_path = Graph.get_shortest_path(map, target_position, position)
        {position, Enum.count(shortest_path) - 1}
      end)
      |> Enum.max_by(fn {_, path_length} -> path_length end)

    greatest_path_length
  end

  def find_target(memory) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])
    droid = Task.async(RepairDroid, :initialize, [%{cpu: cpu}])

    cpu_input_fn = fn -> send(droid.pid, :move_req) end
    Interpreter.set_input_fn(cpu, cpu_input_fn)

    cpu_output_fn = fn value -> send(droid.pid, {:status, value}) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(droid.pid, :start)

    {:halt, %{state: :term} = state} = Task.await(droid, :infinity)
    send(cpu.pid, :term)
    {:halt, _} = Task.await(cpu, :infinity)

    state
  end
end

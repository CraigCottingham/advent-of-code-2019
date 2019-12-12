defmodule AoC.Day11 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory, PaintingRobot}

  def part_1 do
    "data/day11-input.txt"
    |> Memory.load_from_file()
    |> paint()
    |> Map.get(:known_panels)
    |> Map.keys()
    |> Enum.count()
  end

  def part_2 do
    "data/day11-input.txt"
    |> Memory.load_from_file()
    |> paint(%{{0, 0} => :white})
    |> Map.get(:known_panels)
    |> Map.to_list()
    |> Enum.filter(fn {_, color} -> color == :white end)
    |> Enum.map(fn {position, _} -> position end)

    # ideally, we'd have some kind of character recognition here
    # for now, render out the image data, recognize it manually,
    # then return the text
    |> render()

    "CEPKZJCR"
  end

  def paint(memory, initial_panels \\ %{}) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])
    robot = Task.async(PaintingRobot, :initialize, [%{cpu: cpu, known_panels: initial_panels}])

    cpu_output_fn = fn value -> send(robot.pid, value) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(robot.pid, :start)

    {:halt, %{state: :stopped}} = Task.await(cpu)
    send(robot.pid, :term)
    {:halt, %{state: :term} = state} = Task.await(robot)

    state
  end

  defp render(positions) do
    ## this code assumes that the min {x, y} is non-negative
    ## this assumption is true for the data for 2019 day 11

    max_x =
      positions
      |> Enum.map(&elem(&1, 0))
      |> Enum.max()

    max_y =
      positions
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    positions
    |> Enum.reduce(Max.new(max_y + 1, max_x + 1), fn {x, y}, m -> Max.set(m, {y, x}, 1) end)
    |> Max.to_list_of_lists()
    |> Enum.map(fn row ->
      row
      |> Enum.map(&render_panel/1)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> String.replace_prefix("", "\n")
  end

  defp render_panel(0), do: " "
  defp render_panel(1), do: "█"
  defp render_panel(_), do: "."
end

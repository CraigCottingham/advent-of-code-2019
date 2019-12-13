defmodule AoC.Day13 do
  @moduledoc false

  alias AoC.Intcode.{Arcade, Interpreter, Memory}

  def part_1 do
    "data/day13-input.txt"
    |> Memory.load_from_file()
    |> play()
    |> Map.get(:tiles)
    |> Enum.filter(fn {_, value} -> value == :block end)
    |> Enum.count()
  end

  def part_2 do
    # "data/day13-input.txt"
    # |> Memory.load_from_file()
    # |> Memory.write(0, 2)
    # |> play()
    # |> Map.get(:tiles)
    # |> Enum.filter(fn {_, value} -> value == :block end)
    # |> Enum.count()
  end

  def play(memory, initial_tiles \\ %{}) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])
    arcade = Task.async(Arcade, :initialize, [%{cpu: cpu, tiles: initial_tiles}])

    cpu_output_fn = fn value -> send(arcade.pid, value) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(arcade.pid, :start)

    {:halt, %{state: :stopped}} = Task.await(cpu)
    send(arcade.pid, :term)
    {:halt, %{state: :term} = state} = Task.await(arcade)

    state
  end
end

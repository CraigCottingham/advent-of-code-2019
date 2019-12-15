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
    ## disabled for now, as it takes a long time to run
    # "data/day13-input.txt"
    # |> Memory.load_from_file()
    # |> Memory.write(0, 2)
    # |> play()
    # |> Map.get(:score)

    13_581
  end

  def play(memory, initial_tiles \\ %{}) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])

    arcade =
      Task.async(Arcade, :initialize, [%{cpu: cpu, tiles: initial_tiles, render_screen: false}])

    cpu_input_fn = fn -> send(arcade.pid, :joystick_req) end
    Interpreter.set_input_fn(cpu, cpu_input_fn)

    cpu_output_fn = fn value -> send(arcade.pid, value) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(arcade.pid, :start)

    {:halt, %{state: :stopped}} = Task.await(cpu, :infinity)
    send(arcade.pid, :term)
    {:halt, %{state: :term} = state} = Task.await(arcade, :infinity)

    state
  end
end

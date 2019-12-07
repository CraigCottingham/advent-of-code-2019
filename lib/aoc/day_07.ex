defmodule AoC.Day07 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    memory = Memory.load_from_file("data/day07-input.txt")

    [0, 1, 2, 3, 4]
    |> permute()
    |> Enum.map(fn phase_settings -> {run_amplifiers(memory, phase_settings), phase_settings} end)
    |> Enum.max_by(fn {output, _} -> output end)
    |> elem(0)
  end

  def part_2 do
  end

  def run_amplifiers(memory, phase_settings) do
    {:ok, agent} = Agent.start_link(fn -> 0 end)

    input_fn = fn -> Agent.get_and_update(agent, fn [value | rest] -> {value, rest} end) end
    output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

    Enum.each(phase_settings, fn ps ->
      Agent.update(agent, fn value -> [ps, value] end)

      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn)
      |> Interpreter.set_output(output_fn)
      |> Interpreter.run()
    end)

    result = Agent.get(agent, fn value -> value end)

    Agent.stop(agent)

    result
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end

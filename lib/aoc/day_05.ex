defmodule AoC.Day05 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    {:ok, agent} = Agent.start_link(fn -> nil end)
    input_fn = fn -> 1 end
    output_fn = fn value -> Agent.update(agent, fn _ -> value end) end
    memory = Memory.load_from_file("data/day05-input.txt")

    Interpreter.initialize()
    |> Interpreter.set_memory(memory)
    |> Interpreter.set_input(input_fn)
    |> Interpreter.set_output(output_fn)
    |> Interpreter.run()

    result = Agent.get(agent, fn value -> value end)
    Agent.stop(agent)

    result
  end

  def part_2 do
  end
end

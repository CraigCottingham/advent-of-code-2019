defmodule AoC.Day09 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    output_fn = fn value -> Agent.update(agent, fn buffer -> [buffer, value] end) end
    memory = Memory.load_from_file("data/day09-input.txt")

    vm =
      Task.async(Interpreter, :initialize, [
        %{state: :running, memory: memory, output_fn: output_fn}
      ])

    send(vm.pid, 1)
    {:halt, %{state: :stopped}} = Task.await(vm)

    output =
      agent
      |> Agent.get(fn value -> value end)
      |> List.flatten()

    Agent.stop(agent)

    List.first(output)
  end

  def part_2 do
  end
end

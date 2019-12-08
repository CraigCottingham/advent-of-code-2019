defmodule AoC.Day05 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    {:ok, agent} = Agent.start_link(fn -> nil end)
    output_fn = fn value -> Agent.update(agent, fn _ -> value end) end
    memory = Memory.load_from_file("data/day05-input.txt")

    vm = Task.async(Interpreter, :initialize, [%{memory: memory, output_fn: output_fn}])
    send(vm.pid, 1)
    {:halt, %{state: :stopped}} = Task.await(vm)

    result = Agent.get(agent, fn value -> value end)
    Agent.stop(agent)

    result
  end

  def part_2 do
    {:ok, agent} = Agent.start_link(fn -> nil end)
    output_fn = fn value -> Agent.update(agent, fn _ -> value end) end
    memory = Memory.load_from_file("data/day05-input.txt")

    vm = Task.async(Interpreter, :initialize, [%{memory: memory, output_fn: output_fn}])
    send(vm.pid, 5)
    {:halt, %{state: :stopped}} = Task.await(vm)

    result = Agent.get(agent, fn value -> value end)
    Agent.stop(agent)

    result
  end
end

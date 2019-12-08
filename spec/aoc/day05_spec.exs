defmodule AoC.Day05.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  describe "sanity checks" do
    it "tests the input and output opcodes" do
      {:ok, agent} = Agent.start_link(fn -> nil end)
      output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

      vm =
        Task.async(Interpreter, :initialize, [
          %{state: :running, memory: [3, 0, 4, 0, 99], output_fn: output_fn}
        ])

      send(vm.pid, 99)
      {:halt, %{state: :stopped, memory: final_memory}} = Task.await(vm)

      expect(final_memory) |> to(eq([99, 0, 4, 0, 99]))
      expect(Agent.get(agent, fn value -> value end) |> to(eq(99)))

      Agent.stop(agent)
    end

    it "tests parameter modes" do
      vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: [1002, 4, 3, 4, 33]}])
      {:halt, %{memory: memory}} = Task.await(vm)
      expect(memory) |> to(eq([1002, 4, 3, 4, 99]))
    end

    it "tests negative integers" do
      vm =
        Task.async(Interpreter, :initialize, [%{state: :running, memory: [1101, 100, -1, 4, 0]}])

      {:halt, %{memory: memory}} = Task.await(vm)
      expect(memory) |> to(eq([1101, 100, -1, 4, 99]))
    end
  end
end

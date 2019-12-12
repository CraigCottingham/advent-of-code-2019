defmodule AoC.Day11.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  describe "sanity checks" do
    it "runs a simple program" do
      {:ok, agent} = Agent.start_link(fn -> [] end)
      output_fn = fn value -> Agent.update(agent, fn buffer -> [buffer, value] end) end

      vm =
        Task.async(Interpreter, :initialize, [
          %{state: :running, memory: [3, 7, 104, 1, 104, 0, 99, 0], output_fn: output_fn}
        ])

      send(vm.pid, 0)

      {:halt, %{state: :stopped}} = Task.await(vm)

      output =
        agent
        |> Agent.get(fn value -> value end)
        |> List.flatten()

      Agent.stop(agent)

      expect(output) |> to(eq([1, 0]))
    end

    it "runs a simple painting robot" do
      memory = [3, 7, 104, 1, 104, 0, 99, 0]
      %{known_panels: panels, position: position, heading: heading} = AoC.Day11.paint(memory)

      expect(Map.keys(panels)) |> to(eq([{0, 0}]))
      expect(Map.get(panels, {0, 0})) |> to(eq(:white))
      expect(position) |> to(eq({-1, 0}))
      expect(heading) |> to(eq(:left))
    end
  end
end

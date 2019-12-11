defmodule AoC.Day11.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, PaintingRobot}

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
      {:ok, turtle} = PaintingRobot.initialize(%{memory: [3, 7, 104, 1, 104, 0, 99, 0]})
      turtle = PaintingRobot.write_camera(turtle, :black)
      {:ok, instructions, turtle} = wait_for_instructions(PaintingRobot.read_instructions(turtle))
      turtle = PaintingRobot.execute_instructions(turtle, instructions)
      turtle = PaintingRobot.stop(turtle)
      expect(instructions) |> to(eq([1, 0]))
      expect(Map.keys(turtle.known_panels)) |> to(eq([{0, 0}]))
      expect(Map.get(turtle.known_panels, {0, 0})) |> to(eq(:white))
      expect(turtle.position) |> to(eq({-1, 0}))
      expect(turtle.heading) |> to(eq(:left))
    end
  end

  defp wait_for_instructions({:blocked, turtle}), do: wait_for_instructions(PaintingRobot.read_instructions(turtle))
  defp wait_for_instructions(success), do: success
end

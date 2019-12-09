defmodule AoC.Day09.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  describe "sanity checks" do
    example_group "relative mode" do
      it do
        {:ok, agent} = Agent.start_link(fn -> [] end)
        output_fn = fn value -> Agent.update(agent, fn buffer -> [buffer, value] end) end

        program = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: program, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        output =
          agent
          |> Agent.get(fn value -> value end)
          |> List.flatten()

        Agent.stop(agent)

        expect(output) |> to(eq(program))
      end
    end

    example_group "large numbers" do
      it "tests multiplying large numbers" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        program = [1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: program, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        output =
          agent
          |> Agent.get(fn value -> value end)
          |> Integer.to_string()

        Agent.stop(agent)

        expect(String.length(output)) |> to(eq(16))
      end

      it "tests outputting large numbers" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        large_integer = 1_125_899_906_842_624
        program = [104, large_integer, 99]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: program, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        output = Agent.get(agent, fn value -> value end)

        Agent.stop(agent)

        expect(output) |> to(eq(large_integer))
      end
    end
  end
end

defmodule AoC.Day05.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  describe "sanity checks" do
    it "tests the input and output opcodes" do
      {:ok, agent} = Agent.start_link(fn -> nil end)
      input_fn = fn -> 99 end
      output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

      Interpreter.initialize()
      |> Interpreter.set_memory([3, 0, 4, 0, 99])
      |> Interpreter.set_input(input_fn)
      |> Interpreter.set_output(output_fn)
      |> Interpreter.run()
      |> expect()
      |> to(eq([99, 0, 4, 0, 99]))

      expect(Agent.get(agent, fn value -> value end) |> to(eq(99)))

      Agent.stop(agent)
    end

    it "tests parameter modes" do
      Interpreter.initialize()
      |> Interpreter.set_memory([1002, 4, 3, 4, 33])
      |> Interpreter.run()
      |> expect()
      |> to(eq([1002, 4, 3, 4, 99]))
    end

    it "tests negative integers" do
      Interpreter.initialize()
      |> Interpreter.set_memory([1101, 100, -1, 4, 0])
      |> Interpreter.run()
      |> expect()
      |> to(eq([1101, 100, -1, 4, 99]))
    end
  end
end

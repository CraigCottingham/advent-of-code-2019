defmodule AoC.Day02.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, Memory}

  describe "sanity checks" do
    it "tests run_intcode_program/2" do
      {:halt, %{memory: memory}} =
        Interpreter.initialize()
        |> Interpreter.set_memory([1, 0, 0, 0, 99])
        |> Interpreter.run()

      expect(memory) |> to(eq([2, 0, 0, 0, 99]))

      {:halt, %{memory: memory}} =
        Interpreter.initialize()
        |> Interpreter.set_memory([2, 3, 0, 3, 99])
        |> Interpreter.run()

      expect(memory) |> to(eq([2, 3, 0, 6, 99]))

      {:halt, %{memory: memory}} =
        Interpreter.initialize()
        |> Interpreter.set_memory([2, 4, 4, 5, 99, 0])
        |> Interpreter.run()

      expect(memory) |> to(eq([2, 4, 4, 5, 99, 9801]))

      {:halt, %{memory: memory}} =
        Interpreter.initialize()
        |> Interpreter.set_memory([1, 1, 1, 4, 99, 5, 6, 0, 99])
        |> Interpreter.run()

      expect(memory) |> to(eq([30, 1, 1, 4, 2, 5, 6, 0, 99]))
    end

    it "tests run_intcode_program/2 with varying input" do
      memory = Memory.load_from_file("data/day02-input.txt")

      [
        {0, 0},
        {0, 1},
        {1, 0},
        {12, 0},
        {12, 2},
        {33, 76}
      ]
      |> Enum.each(fn {noun, verb} ->
        initial_memory =
          memory
          |> AoC.Day02.set_noun(noun)
          |> AoC.Day02.set_verb(verb)

        {:halt, %{state: :stopped, memory: final_memory}} =
          Interpreter.initialize()
          |> Interpreter.set_memory(initial_memory)
          |> Interpreter.run()

        expect(Memory.read(final_memory, 0)) |> to(eq(noun * 576_000 + verb + 682_644))
      end)
    end
  end
end

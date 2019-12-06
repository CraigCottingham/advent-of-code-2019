defmodule AoC.Day02.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, Memory}

  describe "sanity checks" do
    it "tests run_intcode_program/2" do
      Interpreter.initialize()
      |> Interpreter.set_memory([1, 0, 0, 0, 99])
      |> Interpreter.run()
      |> expect()
      |> to(eq([2, 0, 0, 0, 99]))

      Interpreter.initialize()
      |> Interpreter.set_memory([2, 3, 0, 3, 99])
      |> Interpreter.run()
      |> expect()
      |> to(eq([2, 3, 0, 6, 99]))

      Interpreter.initialize()
      |> Interpreter.set_memory([2, 4, 4, 5, 99, 0])
      |> Interpreter.run()
      |> expect()
      |> to(eq([2, 4, 4, 5, 99, 9801]))

      Interpreter.initialize()
      |> Interpreter.set_memory([1, 1, 1, 4, 99, 5, 6, 0, 99])
      |> Interpreter.run()
      |> expect()
      |> to(eq([30, 1, 1, 4, 2, 5, 6, 0, 99]))
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
        mem =
          memory
          |> AoC.Day02.set_noun(noun)
          |> AoC.Day02.set_verb(verb)

        output =
          Interpreter.initialize()
          |> Interpreter.set_memory(mem)
          |> Interpreter.run()
          |> Memory.read(0)

        expect(output) |> to(eq(noun * 576_000 + verb + 682_644))
      end)
    end
  end
end

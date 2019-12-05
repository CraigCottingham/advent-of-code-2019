defmodule AoC.Day02.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, Memory}

  describe "sanity checks" do
    it "tests run_intcode_program/2" do
      expect(Interpreter.run([1, 0, 0, 0, 99])) |> to(eq([2, 0, 0, 0, 99]))
      expect(Interpreter.run([2, 3, 0, 3, 99])) |> to(eq([2, 3, 0, 6, 99]))

      expect(Interpreter.run([2, 4, 4, 5, 99, 0]))
      |> to(eq([2, 4, 4, 5, 99, 9801]))

      expect(Interpreter.run([1, 1, 1, 4, 99, 5, 6, 0, 99]))
      |> to(eq([30, 1, 1, 4, 2, 5, 6, 0, 99]))
    end

    it "tests run_intcode_program/2 with varying input" do
      memory = Memory.load_file("data/day02-input.txt")

      [
        {0, 0},
        {0, 1},
        {1, 0},
        {12, 0},
        {12, 2},
        {33, 76}
      ]
      |> Enum.each(fn {noun, verb} ->
        output =
          memory
          |> Memory.set_noun(noun)
          |> Memory.set_verb(verb)
          |> Interpreter.run()
          |> Enum.at(0)

        expect(output) |> to(eq(noun * 576_000 + verb + 682_644))
      end)
    end
  end
end

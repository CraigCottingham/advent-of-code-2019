defmodule AoC.Day02.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests run_intcode_program/2" do
      expect(AoC.Day02.run_intcode_program([1, 0, 0, 0, 99])) |> to(eq([2, 0, 0, 0, 99]))
      expect(AoC.Day02.run_intcode_program([2, 3, 0, 3, 99])) |> to(eq([2, 3, 0, 6, 99]))
      expect(AoC.Day02.run_intcode_program([2, 4, 4, 5, 99, 0])) |> to(eq([2, 4, 4, 5, 99, 9801]))
      expect(AoC.Day02.run_intcode_program([1, 1, 1, 4, 99, 5, 6, 0, 99])) |> to(eq([30, 1, 1, 4, 2, 5, 6, 0, 99]))
    end

    it "tests run_intcode_program/2 with varying input" do
      program = AoC.Day02.load_program("data/day02-input.txt")

      [
        {0,  0},
        {0,  1},
        {1,  0},
        {12, 0},
        {12, 2},
        {33, 76}
      ]
      |> Enum.each(fn {noun, verb} ->
        output =
          program
          |> AoC.Day02.run_intcode_program({noun, verb})
          |> Enum.at(0)
        expect(output) |> to(eq(
          (noun * 576_000) + verb + 682644
        ))
      end)
    end
  end
end

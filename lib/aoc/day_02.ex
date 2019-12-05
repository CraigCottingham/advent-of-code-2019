defmodule AoC.Day02 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    "data/day02-input.txt"
    |> Memory.load_file()
    |> Interpreter.run({12, 2})
    |> Enum.at(0)
  end

  def part_2 do
    program = Memory.load_file("data/day02-input.txt")

    results =
      for noun <- 0..99, verb <- 0..99 do
        output =
          program
          |> Interpreter.run({noun, verb})
          |> Enum.at(0)

        {noun, verb, output}
      end

    case Enum.find(results, fn {_, _, value} -> value == 19_690_720 end) do
      {noun, verb, 19_690_720} -> noun * 100 + verb
      _ -> :error
    end
  end
end

defmodule AoC.Day02 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    "data/day02-input.txt"
    |> Memory.load_file()
    |> set_noun(12)
    |> set_verb(2)
    |> Interpreter.run()
    |> Enum.at(0)
  end

  def part_2 do
    memory = Memory.load_file("data/day02-input.txt")

    results =
      for noun <- 0..99, verb <- 0..99 do
        output =
          memory
          |> set_noun(noun)
          |> set_verb(verb)
          |> Interpreter.run()
          |> Enum.at(0)

        {noun, verb, output}
      end

    case Enum.find(results, fn {_, _, value} -> value == 19_690_720 end) do
      {noun, verb, 19_690_720} -> noun * 100 + verb
      _ -> :error
    end
  end

  def set_noun(mem, nil), do: mem
  def set_noun(mem, noun), do: List.replace_at(mem, 1, noun)

  def set_verb(mem, nil), do: mem
  def set_verb(mem, verb), do: List.replace_at(mem, 2, verb)
end

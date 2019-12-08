defmodule AoC.Day02 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    initial_memory =
      "data/day02-input.txt"
      |> Memory.load_from_file()
      |> set_noun(12)
      |> set_verb(2)

    vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: initial_memory}])
    {:halt, %{state: :stopped, memory: final_memory}} = Task.await(vm)
    Memory.read(final_memory, 0)
  end

  def part_2 do
    memory = Memory.load_from_file("data/day02-input.txt")

    results =
      for noun <- 0..99, verb <- 0..99 do
        initial_memory =
          memory
          |> set_noun(noun)
          |> set_verb(verb)

        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: initial_memory}])
        {:halt, %{state: :stopped, memory: final_memory}} = Task.await(vm)
        {noun, verb, Memory.read(final_memory, 0)}
      end

    case Enum.find(results, fn {_, _, value} -> value == 19_690_720 end) do
      {noun, verb, 19_690_720} -> noun * 100 + verb
      _ -> :error
    end
  end

  def set_noun(mem, nil), do: mem
  def set_noun(mem, noun), do: Memory.write(mem, 1, noun)

  def set_verb(mem, nil), do: mem
  def set_verb(mem, verb), do: Memory.write(mem, 2, verb)
end

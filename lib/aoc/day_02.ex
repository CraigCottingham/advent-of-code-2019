defmodule AoC.Day02 do
  @moduledoc false

  alias AoC.Intcode.Memory

  def part_1 do
    "data/day02-input.txt"
    |> Memory.load_file()
    |> run_intcode_program({12, 2})
    |> Enum.at(0)
  end

  def part_2 do
    program = Memory.load_file("data/day02-input.txt")

    results =
      for noun <- 0..99, verb <- 0..99 do
        output =
          program
          |> run_intcode_program({noun, verb})
          |> Enum.at(0)

        {noun, verb, output}
      end

    case Enum.find(results, fn {_, _, value} -> value == 19_690_720 end) do
      {noun, verb, 19_690_720} -> noun * 100 + verb
      _ -> :error
    end
  end

  # def load_program(filename) do
  #   filename
  #   |> File.stream!()
  #   |> Enum.map(&String.trim/1)
  #   |> List.first()
  #   |> String.split(",")
  #   |> Enum.map(&String.trim/1)
  #   |> Enum.map(&String.to_integer/1)
  # end

  def run_intcode_program(program, {noun, verb} \\ {nil, nil}) do
    mem =
      program
      |> set_noun(noun)
      |> set_verb(verb)

    case step_program({:cont, mem, 0}) do
      {:halt, mem} ->
        mem

      {:error, mem, ip} ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        nil
    end
  end

  defp set_noun(mem, nil), do: mem
  defp set_noun(mem, noun), do: List.replace_at(mem, 1, noun)

  defp set_verb(mem, nil), do: mem
  defp set_verb(mem, verb), do: List.replace_at(mem, 2, verb)

  defp step_program({:cont, program, ip}) do
    case Enum.at(program, ip) do
      # add
      1 ->
        source_1 = Enum.at(program, ip + 1)
        source_2 = Enum.at(program, ip + 2)
        dest = Enum.at(program, ip + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step_program({:cont, List.replace_at(program, dest, addend_1 + addend_2), ip + 4})

      # multiply
      2 ->
        source_1 = Enum.at(program, ip + 1)
        source_2 = Enum.at(program, ip + 2)
        dest = Enum.at(program, ip + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step_program({:cont, List.replace_at(program, dest, addend_1 * addend_2), ip + 4})

      # exit
      99 ->
        {:halt, program}

      _ ->
        {:error, program, ip}
    end
  end
end

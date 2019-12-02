defmodule AoC.Day02 do
  @moduledoc false

  def part_1 do
    File.stream!("data/day02-input.txt")
    |> Enum.map(&String.trim/1)
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> run_intcode_program()
    |> Enum.at(0)
  end

  def run_intcode_program(program) do
    case step_program({:cont, program, 0}) do
      {:halt, p} ->
        p

      {:error, p, pc} ->
        IO.puts("error at position #{pc}: #{inspect(p)}")
        nil
    end
  end

  def step_program({:cont, program, pc}) do
    case Enum.at(program, pc) do
      # add
      1 ->
        source_1 = Enum.at(program, pc + 1)
        source_2 = Enum.at(program, pc + 2)
        dest = Enum.at(program, pc + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step_program({:cont, List.replace_at(program, dest, addend_1 + addend_2), pc + 4})

      # multiply
      2 ->
        source_1 = Enum.at(program, pc + 1)
        source_2 = Enum.at(program, pc + 2)
        dest = Enum.at(program, pc + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step_program({:cont, List.replace_at(program, dest, addend_1 * addend_2), pc + 4})

      # exit
      99 ->
        {:halt, program}

      _ ->
        {:error, program, pc}
    end
  end
end

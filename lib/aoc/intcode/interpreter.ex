defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  alias AoC.Intcode.Memory

  def run(program, {noun, verb} \\ {nil, nil}) do
    mem =
      program
      |> Memory.set_noun(noun)
      |> Memory.set_verb(verb)

    case step({:cont, mem, 0}) do
      {:halt, mem} ->
        mem

      {:error, mem, ip} ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        nil
    end
  end

  defp step({:cont, program, ip}) do
    case Enum.at(program, ip) do
      # add
      1 ->
        source_1 = Enum.at(program, ip + 1)
        source_2 = Enum.at(program, ip + 2)
        dest = Enum.at(program, ip + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step({:cont, List.replace_at(program, dest, addend_1 + addend_2), ip + 4})

      # multiply
      2 ->
        source_1 = Enum.at(program, ip + 1)
        source_2 = Enum.at(program, ip + 2)
        dest = Enum.at(program, ip + 3)

        addend_1 = Enum.at(program, source_1)
        addend_2 = Enum.at(program, source_2)
        step({:cont, List.replace_at(program, dest, addend_1 * addend_2), ip + 4})

      # exit
      99 ->
        {:halt, program}

      _ ->
        {:error, program, ip}
    end
  end
end

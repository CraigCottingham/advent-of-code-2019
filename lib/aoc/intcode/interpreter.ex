defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  def run(memory) do
    state = %{memory: memory, ip: 0}

    case step(state) do
      {:halt, %{memory: mem}} ->
        mem

      {:error, %{memory: mem, ip: ip}} ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        nil
    end
  end

  defp step(%{memory: memory, ip: ip} = state) do
    case Enum.at(memory, ip) do
      # add
      1 ->
        source_1 = Enum.at(memory, ip + 1)
        source_2 = Enum.at(memory, ip + 2)
        dest = Enum.at(memory, ip + 3)

        value_1 = Enum.at(memory, source_1)
        value_2 = Enum.at(memory, source_2)
        step(%{state | memory: List.replace_at(memory, dest, value_1 + value_2), ip: ip + 4})

      # multiply
      2 ->
        source_1 = Enum.at(memory, ip + 1)
        source_2 = Enum.at(memory, ip + 2)
        dest = Enum.at(memory, ip + 3)

        value_1 = Enum.at(memory, source_1)
        value_2 = Enum.at(memory, source_2)
        step(%{state | memory: List.replace_at(memory, dest, value_1 * value_2), ip: ip + 4})

      # exit
      99 ->
        {:halt, state}

      _ ->
        {:error, state}
    end
  end
end

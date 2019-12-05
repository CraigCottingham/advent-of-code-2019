defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  alias AoC.Intcode.Memory

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
    case Memory.read(memory, ip) do
      # add
      1 ->
        source_1 = Memory.read(memory, ip + 1)
        source_2 = Memory.read(memory, ip + 2)
        dest = Memory.read(memory, ip + 3)

        value_1 = Memory.read(memory, source_1)
        value_2 = Memory.read(memory, source_2)
        result = value_1 + value_2

        step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})

      # multiply
      2 ->
        source_1 = Memory.read(memory, ip + 1)
        source_2 = Memory.read(memory, ip + 2)
        dest = Memory.read(memory, ip + 3)

        value_1 = Memory.read(memory, source_1)
        value_2 = Memory.read(memory, source_2)
        result = value_1 * value_2

        step(%{state | memory: List.replace_at(memory, dest, result), ip: ip + 4})

      # exit
      99 ->
        {:halt, state}

      _ ->
        {:error, state}
    end
  end
end

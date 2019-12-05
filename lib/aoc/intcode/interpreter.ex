defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  alias AoC.Intcode.Memory

  def initialize do
    %{memory: [], ip: 0, input_fn: nil, output_fn: nil}
  end

  def run(state) do
    case step(state) do
      {:halt, %{memory: mem}} ->
        mem

      {:error, %{memory: mem, ip: ip}} ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        nil
    end
  end

  def set_input(state, fun), do: %{state | input_fn: fun}
  def set_ip(state, ip), do: %{state | ip: ip}
  def set_memory(state, memory), do: %{state | memory: memory}
  def set_output(state, fun), do: %{state | output_fn: fun}

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

        step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})

      # input
      3 ->
        dest = Memory.read(memory, ip + 1)

        value = state.input_fn.()

        step(%{state | memory: Memory.write(memory, dest, value), ip: ip + 2})

      # exit
      99 ->
        {:halt, state}

      _ ->
        {:error, state}
    end
  end
end

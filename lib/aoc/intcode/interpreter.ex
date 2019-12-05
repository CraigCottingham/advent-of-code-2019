defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  import ExPrintf

  alias AoC.Intcode.Memory

  def initialize do
    %{memory: [], ip: 0, input_fn: nil, output_fn: nil}
  end

  def run(state) do
    case step(state) do
      {:halt, %{memory: mem}} ->
        mem

      {:invalid_opcode, opcode, %{memory: mem, ip: ip}} ->
        IO.puts("invalid opcode (#{opcode}) at position #{ip}: #{inspect(mem)}")
        nil

      {:error, %{memory: mem, ip: ip}} ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        nil
    end
  end

  def set_input(state, fun), do: %{state | input_fn: fun}
  def set_ip(state, ip), do: %{state | ip: ip}
  def set_memory(state, memory), do: %{state | memory: memory}
  def set_output(state, fun), do: %{state | output_fn: fun}

  defp decode(opcode),
    do:
      Regex.named_captures(
        ~r/^(?<mode_3>\d)(?<mode_2>\d)(?<mode_1>\d)(?<instruction>\d{2})$/,
        sprintf("%05d", [opcode])
      )

  defp get_mode("0"), do: :position
  defp get_mode("1"), do: :immediate

  defp get_value(_memory, value, :immediate), do: value
  defp get_value(memory, address, :position), do: Memory.read(memory, address)

  # add
  defp execute(
         %{"instruction" => "01", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))
    result = value_1 + value_2

    step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})
  end

  # multiply
  defp execute(
         %{"instruction" => "02", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))
    result = value_1 * value_2

    step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})
  end

  # input
  defp execute(%{"instruction" => "03"}, %{memory: memory, ip: ip} = state) do
    dest = Memory.read(memory, ip + 1)

    value = state.input_fn.()

    step(%{state | memory: Memory.write(memory, dest, value), ip: ip + 2})
  end

  # output
  defp execute(%{"instruction" => "04", "mode_1" => mode}, %{memory: memory, ip: ip} = state) do
    param = Memory.read(memory, ip + 1)

    value = get_value(memory, param, get_mode(mode))
    state.output_fn.(value)

    step(%{state | ip: ip + 2})
  end

  # jump-if-true
  defp execute(
         %{"instruction" => "05", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))

    new_ip =
      if value_1 == 1 do
        value_2
      else
        ip + 3
      end

    step(%{state | ip: new_ip})
  end

  # jump-if-false
  defp execute(
         %{"instruction" => "06", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))

    new_ip =
      if value_1 == 0 do
        value_2
      else
        ip + 3
      end

    step(%{state | ip: new_ip})
  end

  # less than
  defp execute(
         %{"instruction" => "07", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))

    result =
      if value_1 < value_2 do
        1
      else
        0
      end

    step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})
  end

  # equal
  defp execute(
         %{"instruction" => "08", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(memory, param_1, get_mode(mode_1))
    value_2 = get_value(memory, param_2, get_mode(mode_2))

    result =
      if value_1 == value_2 do
        1
      else
        0
      end

    step(%{state | memory: Memory.write(memory, dest, result), ip: ip + 4})
  end

  # exit
  defp execute(%{"instruction" => "99"}, state) do
    {:halt, state}
  end

  # invalid opcode
  defp execute(%{"instruction" => instruction}, state) do
    {:invalid_opcode, instruction, state}
  end

  # unspecified error
  defp execute(_, state) do
    {:error, state}
  end

  defp step(%{memory: memory, ip: ip} = state) do
    memory
    |> Memory.read(ip)
    |> decode()
    |> execute(state)
  end
end

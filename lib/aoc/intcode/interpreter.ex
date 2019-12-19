defmodule AoC.Intcode.Interpreter do
  @moduledoc false

  use Task

  import ExPrintf

  alias AoC.Intcode.Memory

  def initialize(initial_state) do
    %{
      state: :ready,
      memory: [],
      ip: 0,
      rp: 0,
      input_fn: fn -> nil end,
      output_fn: nil,
      trace: false,
      trace_prefix: "",
      ip_width: 4
    }
    |> Map.merge(initial_state)
    |> run()
  end

  def start(task) do
    send(task.pid, :start)
    task
  end

  def set_input_fn(task, input_fn) do
    send(task.pid, {:set_input_fn, input_fn})
    task
  end

  def set_output_fn(task, output_fn) do
    send(task.pid, {:set_output_fn, output_fn})
    task
  end

  def run(%{state: :ready} = state) do
    receive do
      :start ->
        run(%{state | state: :running})

      :term ->
        {:halt, %{state | state: :term}}

      {:set_input_fn, fun} ->
        run(%{state | input_fn: fun})

      {:set_output_fn, fun} ->
        run(%{state | output_fn: fun})
    end
  end

  def run(state) do
    case step(state) do
      {:cont, state} ->
        run(state)

      {:halt, state} ->
        {:halt, state}

      {:invalid_opcode, opcode, %{memory: mem, ip: ip}} = result ->
        IO.puts("invalid opcode (#{opcode}) at position #{ip}: #{inspect(mem)}")
        result

      {:error, %{memory: mem, ip: ip}} = result ->
        IO.puts("error at position #{ip}: #{inspect(mem)}")
        result
    end
  end

  def set_memory(state, memory) do
    ip_width =
      memory
      |> Enum.count()
      |> :math.log10()
      |> ceil()
      |> trunc()

    %{state | memory: memory, ip_width: ip_width}
  end

  def set_trace(state, true), do: %{state | trace: true}
  def set_trace(state, false), do: %{state | trace: false}
  def set_trace_prefix(state, prefix), do: %{state | trace_prefix: prefix}

  defp decode(opcode),
    do:
      Regex.named_captures(
        ~r/^(?<mode_3>\d)(?<mode_2>\d)(?<mode_1>\d)(?<instruction>\d{2})$/,
        sprintf("%05d", [opcode])
      )

  # add
  defp execute(
         %{"instruction" => "01", "mode_1" => mode_1, "mode_2" => mode_2, "mode_3" => mode_3},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))
    result = value_1 + value_2

    trace3(
      "ADD",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      {dest, result, get_mode(mode_3)},
      state
    )

    {:cont, %{state | memory: put_value(state, dest, result, get_mode(mode_3)), ip: ip + 4}}
  end

  # multiply
  defp execute(
         %{"instruction" => "02", "mode_1" => mode_1, "mode_2" => mode_2, "mode_3" => mode_3},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))
    result = value_1 * value_2

    trace3(
      "MUL",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      {dest, result, get_mode(mode_3)},
      state
    )

    {:cont, %{state | memory: put_value(state, dest, result, get_mode(mode_3)), ip: ip + 4}}
  end

  # input
  defp execute(
         %{"instruction" => "03", "mode_1" => mode_1},
         %{memory: memory, ip: ip, input_fn: input_fn} = state
       ) do
    case get_mode(mode_1) do
      :position ->
        dest = Memory.read(memory, ip + 1)
        input_fn.()

        receive do
          :term ->
            {:halt, %{state | state: :term}}

          value when not is_integer(value) ->
            raise "IN read a non-integer: #{inspect(value)}"

          value ->
            trace1(
              "IN",
              {dest, value, get_mode(mode_1)},
              state
            )

            {:cont, %{state | memory: Memory.write(memory, dest, value), ip: ip + 2}}
        end

      :immediate ->
        {:invalid_opcode, Memory.read(memory, ip), state}

      :relative ->
        dest = Memory.read(memory, ip + 1) + state.rp
        input_fn.()

        receive do
          :term ->
            {:halt, %{state | state: :term}}

          value ->
            trace1(
              "IN",
              {dest, value, get_mode(mode_1)},
              state
            )

            {:cont, %{state | memory: Memory.write(memory, dest, value), ip: ip + 2}}
        end
    end
  end

  # output
  defp execute(
         %{"instruction" => "04", "mode_1" => mode},
         %{memory: memory, ip: ip, output_fn: output_fn} = state
       ) do
    param = Memory.read(memory, ip + 1)

    value = get_value(state, param, get_mode(mode))
    output_fn.(value)

    trace1(
      "OUT",
      {param, value, get_mode(mode)},
      state
    )

    {:cont, %{state | ip: ip + 2}}
  end

  # jump-if-true
  defp execute(
         %{"instruction" => "05", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))

    new_ip =
      if value_1 != 0 do
        value_2
      else
        ip + 3
      end

    trace2(
      "JMPT",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      state
    )

    {:cont, %{state | ip: new_ip}}
  end

  # jump-if-false
  defp execute(
         %{"instruction" => "06", "mode_1" => mode_1, "mode_2" => mode_2},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))

    new_ip =
      if value_1 == 0 do
        value_2
      else
        ip + 3
      end

    trace2(
      "JMPF",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      state
    )

    {:cont, %{state | ip: new_ip}}
  end

  # less than
  defp execute(
         %{"instruction" => "07", "mode_1" => mode_1, "mode_2" => mode_2, "mode_3" => mode_3},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))

    result =
      if value_1 < value_2 do
        1
      else
        0
      end

    trace3(
      "IFLT",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      {dest, result, get_mode(mode_3)},
      state
    )

    {:cont, %{state | memory: put_value(state, dest, result, get_mode(mode_3)), ip: ip + 4}}
  end

  # equal
  defp execute(
         %{"instruction" => "08", "mode_1" => mode_1, "mode_2" => mode_2, "mode_3" => mode_3},
         %{memory: memory, ip: ip} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    param_2 = Memory.read(memory, ip + 2)
    dest = Memory.read(memory, ip + 3)

    value_1 = get_value(state, param_1, get_mode(mode_1))
    value_2 = get_value(state, param_2, get_mode(mode_2))

    result =
      if value_1 == value_2 do
        1
      else
        0
      end

    trace3(
      "IFEQ",
      {param_1, value_1, get_mode(mode_1)},
      {param_2, value_2, get_mode(mode_2)},
      {dest, result, get_mode(mode_3)},
      state
    )

    {:cont, %{state | memory: put_value(state, dest, result, get_mode(mode_3)), ip: ip + 4}}
  end

  # adjust relative base
  defp execute(
         %{"instruction" => "09", "mode_1" => mode_1},
         %{memory: memory, ip: ip, rp: rp} = state
       ) do
    param_1 = Memory.read(memory, ip + 1)
    value_1 = get_value(state, param_1, get_mode(mode_1))
    new_rp = rp + value_1

    trace2(
      "RP",
      {param_1, value_1, get_mode(mode_1)},
      {new_rp, new_rp, :immediate},
      state
    )

    {:cont, %{state | ip: ip + 2, rp: new_rp}}
  end

  # halt
  defp execute(%{"instruction" => "99"}, state) do
    trace0(
      "HALT",
      state
    )

    {:halt, %{state | state: :stopped}}
  end

  # invalid opcode
  defp execute(%{"instruction" => instruction}, state) do
    {:invalid_opcode, instruction, state}
  end

  # unspecified error
  defp execute(_, state) do
    {:error, state}
  end

  defp get_mode("0"), do: :position
  defp get_mode("1"), do: :immediate
  defp get_mode("2"), do: :relative

  defp get_value(state, address, :position), do: Memory.read(state.memory, address)
  defp get_value(_state, value, :immediate), do: value
  defp get_value(state, address, :relative), do: Memory.read(state.memory, address + state.rp)

  defp put_value(state, address, value, :position), do: Memory.write(state.memory, address, value)

  defp put_value(state, address, value, :relative),
    do: Memory.write(state.memory, address + state.rp, value)

  defp step(%{memory: memory, ip: ip} = state) do
    memory
    |> Memory.read(ip)
    |> decode()
    |> execute(state)
  end

  defp trace0(_, %{trace: false}), do: nil

  defp trace0(mnemonic, %{trace: true} = state) do
    "#{state.trace_prefix}%0#{state.ip_width}d:  %-4s"
    |> sprintf([state.ip, mnemonic])
    |> IO.puts()
  end

  defp trace1(_, _, %{trace: false}), do: nil

  defp trace1(mnemonic, param_1, %{trace: true} = state) do
    "#{state.trace_prefix}%0#{state.ip_width}d:  %-4s %s"
    |> sprintf([state.ip, mnemonic, vstr(param_1)])
    |> IO.puts()
  end

  defp trace2(_, _, _, %{trace: false}), do: nil

  defp trace2(mnemonic, param_1, param_2, %{trace: true} = state) do
    "#{state.trace_prefix}%0#{state.ip_width}d:  %-4s %s -> %s"
    |> sprintf([state.ip, mnemonic, vstr(param_1), vstr(param_2)])
    |> IO.puts()
  end

  defp trace3(_, _, _, _, %{trace: false}), do: nil

  defp trace3(mnemonic, param_1, param_2, param_3, %{trace: true} = state) do
    "#{state.trace_prefix}%0#{state.ip_width}d:  %-4s %s, %s -> %s"
    |> sprintf([state.ip, mnemonic, vstr(param_1), vstr(param_2), vstr(param_3)])
    |> IO.puts()
  end

  defp vstr({_, value, :immediate}), do: "#{value}"
  defp vstr({param, value, :position}), do: "[#{param}] (#{value})"
  defp vstr({param, value, :relative}), do: "[#{param}] (#{value})"
end

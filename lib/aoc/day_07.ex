defmodule AoC.Day07 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    memory = Memory.load_from_file("data/day07-input.txt")

    [0, 1, 2, 3, 4]
    |> permute()
    |> Enum.map(fn phase_settings -> {run_amplifiers(memory, phase_settings), phase_settings} end)
    |> Enum.max_by(fn {output, _} -> output end)
    |> elem(0)
  end

  def part_2 do
  end

  def run_amplifiers(memory, [ps1, ps2, ps3, ps4, ps5]) do
    {:ok, agent_1} = Agent.start_link(fn -> [ps1, 0] end)
    {:ok, agent_2} = Agent.start_link(fn -> [ps2] end)
    {:ok, agent_3} = Agent.start_link(fn -> [ps3] end)
    {:ok, agent_4} = Agent.start_link(fn -> [ps4] end)
    {:ok, agent_5} = Agent.start_link(fn -> [ps5] end)
    {:ok, agent_out} = Agent.start_link(fn -> nil end)

    input_fn_1 = fn -> Agent.get_and_update(agent_1, fn [value | rest] -> {value, rest} end) end
    input_fn_2 = fn -> Agent.get_and_update(agent_2, fn [value | rest] -> {value, rest} end) end
    input_fn_3 = fn -> Agent.get_and_update(agent_3, fn [value | rest] -> {value, rest} end) end
    input_fn_4 = fn -> Agent.get_and_update(agent_4, fn [value | rest] -> {value, rest} end) end
    input_fn_5 = fn -> Agent.get_and_update(agent_5, fn [value | rest] -> {value, rest} end) end

    output_fn_1 = fn value ->
      Agent.update(agent_2, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_2 = fn value ->
      Agent.update(agent_3, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_3 = fn value ->
      Agent.update(agent_4, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_4 = fn value ->
      Agent.update(agent_5, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_5 = fn value -> Agent.update(agent_out, fn _ -> value end) end

    _vm_1 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_1)
      |> Interpreter.set_output(output_fn_1)
      |> Interpreter.run()

    _vm_2 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_2)
      |> Interpreter.set_output(output_fn_2)
      |> Interpreter.run()

    _vm_3 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_3)
      |> Interpreter.set_output(output_fn_3)
      |> Interpreter.run()

    _vm_4 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_4)
      |> Interpreter.set_output(output_fn_4)
      |> Interpreter.run()

    _vm_5 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_5)
      |> Interpreter.set_output(output_fn_5)
      |> Interpreter.run()

    result = Agent.get(agent_out, fn value -> value end)

    Agent.stop(agent_1)
    Agent.stop(agent_2)
    Agent.stop(agent_3)
    Agent.stop(agent_4)
    Agent.stop(agent_5)
    Agent.stop(agent_out)

    result
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end

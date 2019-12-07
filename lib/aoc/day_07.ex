defmodule AoC.Day07 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, Memory}

  def part_1 do
    memory = Memory.load_from_file("data/day07-input.txt")

    [0, 1, 2, 3, 4]
    |> permute()
    |> Enum.map(fn phase_settings ->
      setup(memory, phase_settings)
      |> run_amplifiers()
      |> shutdown()
    end)
    |> Enum.max_by(fn {output, _} -> output end)
    |> elem(0)
  end

  def part_2 do
    memory = Memory.load_from_file("data/day07-input.txt")

    [5, 6, 7, 8, 9]
    |> permute()
    |> Enum.map(fn phase_settings ->
      setup(memory, phase_settings)
      |> run_amplifiers()
      |> shutdown()
    end)
    |> Enum.max_by(fn {output, _} -> output end)
    |> elem(0)
  end

  def setup(memory, [ps1, ps2, ps3, ps4, ps5] = phase_settings) do
    {:ok, agent1} = Agent.start_link(fn -> [ps1, 0] end)
    {:ok, agent2} = Agent.start_link(fn -> [ps2] end)
    {:ok, agent3} = Agent.start_link(fn -> [ps3] end)
    {:ok, agent4} = Agent.start_link(fn -> [ps4] end)
    {:ok, agent5} = Agent.start_link(fn -> [ps5] end)

    input_fn_1 = fn ->
      Agent.get_and_update(agent1, fn
        [] -> {nil, []}
        [value | rest] -> {value, rest}
      end)
    end

    input_fn_2 = fn ->
      Agent.get_and_update(agent2, fn
        [] -> {nil, []}
        [value | rest] -> {value, rest}
      end)
    end

    input_fn_3 = fn ->
      Agent.get_and_update(agent3, fn
        [] -> {nil, []}
        [value | rest] -> {value, rest}
      end)
    end

    input_fn_4 = fn ->
      Agent.get_and_update(agent4, fn
        [] -> {nil, []}
        [value | rest] -> {value, rest}
      end)
    end

    input_fn_5 = fn ->
      Agent.get_and_update(agent5, fn
        [] -> {nil, []}
        [value | rest] -> {value, rest}
      end)
    end

    output_fn_1 = fn value ->
      Agent.update(agent2, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_2 = fn value ->
      Agent.update(agent3, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_3 = fn value ->
      Agent.update(agent4, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_4 = fn value ->
      Agent.update(agent5, fn list -> Enum.reverse([value | list]) end)
    end

    output_fn_5 = fn value ->
      Agent.update(agent1, fn list -> Enum.reverse([value | list]) end)
    end

    amp1 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_1)
      |> Interpreter.set_output(output_fn_1)

    amp2 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_2)
      |> Interpreter.set_output(output_fn_2)

    amp3 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_3)
      |> Interpreter.set_output(output_fn_3)

    amp4 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_4)
      |> Interpreter.set_output(output_fn_4)

    amp5 =
      Interpreter.initialize()
      |> Interpreter.set_memory(memory)
      |> Interpreter.set_input(input_fn_5)
      |> Interpreter.set_output(output_fn_5)

    %{
      amp1: amp1,
      amp2: amp2,
      amp3: amp3,
      amp4: amp4,
      amp5: amp5,
      agent1: agent1,
      agent2: agent2,
      agent3: agent3,
      agent4: agent4,
      agent5: agent5,
      phase_settings: phase_settings
    }
  end

  def shutdown(
        %{
          agent1: agent1,
          agent2: agent2,
          agent3: agent3,
          agent4: agent4,
          agent5: agent5
        } = amps
      ) do
    result = Agent.get(agent1, fn [value | _] -> value end)

    Agent.stop(agent1)
    Agent.stop(agent2)
    Agent.stop(agent3)
    Agent.stop(agent4)
    Agent.stop(agent5)

    {result, amps}
  end

  def run_amplifiers(%{amp1: amp1, amp2: amp2, amp3: amp3, amp4: amp4, amp5: amp5} = amps) do
    amps =
      case Interpreter.run(amp1) do
        {:halt, new_amp1} ->
          %{amps | amp1: new_amp1}
      end

    amps =
      case Interpreter.run(amp2) do
        {:halt, new_amp2} ->
          %{amps | amp2: new_amp2}
      end

    amps =
      case Interpreter.run(amp3) do
        {:halt, new_amp3} ->
          %{amps | amp3: new_amp3}
      end

    amps =
      case Interpreter.run(amp4) do
        {:halt, new_amp4} ->
          %{amps | amp4: new_amp4}
      end

    amps =
      case Interpreter.run(amp5) do
        {:halt, new_amp5} ->
          %{amps | amp5: new_amp5}
      end

    case amps.amp5.state do
      :blocked ->
        run_amplifiers(amps)

      :stopped ->
        amps
    end
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end

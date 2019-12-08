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
    end)
    |> Enum.max_by(fn output -> output end)
  end

  def part_2 do
    memory = Memory.load_from_file("data/day07-input.txt")

    [5, 6, 7, 8, 9]
    |> permute()
    |> Enum.map(fn phase_settings ->
      setup(memory, phase_settings)
      |> run_amplifiers()
    end)
    |> Enum.max_by(fn output -> output end)
  end

  def setup(memory, [ps1, ps2, ps3, ps4, ps5] = phase_settings) do
    {:ok, agent} = Agent.start_link(fn -> nil end)

    amp1 = Task.async(Interpreter, :initialize, [%{memory: memory}])
    amp2 = Task.async(Interpreter, :initialize, [%{memory: memory}])
    amp3 = Task.async(Interpreter, :initialize, [%{memory: memory}])
    amp4 = Task.async(Interpreter, :initialize, [%{memory: memory}])
    amp5 = Task.async(Interpreter, :initialize, [%{memory: memory}])

    Interpreter.set_output_fn(amp1, fn value -> send(amp2.pid, value) end)
    Interpreter.set_output_fn(amp2, fn value -> send(amp3.pid, value) end)
    Interpreter.set_output_fn(amp3, fn value -> send(amp4.pid, value) end)
    Interpreter.set_output_fn(amp4, fn value -> send(amp5.pid, value) end)

    Interpreter.set_output_fn(amp5, fn value ->
      Agent.update(agent, fn _ -> value end)
      send(amp1.pid, value)
    end)

    Interpreter.start(amp1)
    Interpreter.start(amp2)
    Interpreter.start(amp3)
    Interpreter.start(amp4)
    Interpreter.start(amp5)

    send(amp1.pid, ps1)
    send(amp2.pid, ps2)
    send(amp3.pid, ps3)
    send(amp4.pid, ps4)
    send(amp5.pid, ps5)

    send(amp1.pid, 0)

    %{
      amp1: amp1,
      amp2: amp2,
      amp3: amp3,
      amp4: amp4,
      amp5: amp5,
      phase_settings: phase_settings,
      agent: agent
    }
  end

  def run_amplifiers(
        %{amp1: amp1, amp2: amp2, amp3: amp3, amp4: amp4, amp5: amp5, agent: agent} = amps
      ) do
    case Enum.all?(Task.yield_many([amp1, amp2, amp3, amp4, amp5]), fn
           {_, {:ok, _}} -> true
           {_, {:invalid_opcode, _, _}} -> true
           {_, {:error, _}} -> true
           _ -> false
         end) do
      true ->
        Agent.get(agent, fn value -> value end)

      _ ->
        run_amplifiers(amps)
    end
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end

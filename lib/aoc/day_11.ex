defmodule AoC.Day11 do
  @moduledoc false

  alias AoC.Intcode.{Interpreter, PaintingRobot}

  def part_1 do
  end

  def part_2 do
  end

  def paint(memory) do
    cpu = Task.async(Interpreter, :initialize, [%{memory: memory}])
    robot = Task.async(PaintingRobot, :initialize, [%{cpu: cpu}])

    cpu_output_fn = fn value -> send(robot.pid, value) end
    Interpreter.set_output_fn(cpu, cpu_output_fn)

    send(cpu.pid, :start)
    send(robot.pid, :start)

    {:halt, %{state: :stopped}} = Task.await(cpu)
    send(robot.pid, :term)
    {:halt, %{state: :term} = state} = Task.await(robot)

    state
  end
end

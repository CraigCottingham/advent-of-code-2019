defmodule AoC.Intcode.PaintingRobot do
  @moduledoc false

  use Task

  alias AoC.Intcode.Interpreter

  # def start_link(initial_state) do
  #   Task.start_link(__MODULE__, :initialize, [initial_state])
  # end

  def initialize(initial_state \\ %{}) do
    %{
      vm: nil,
      memory: nil,
      output: nil,
      position: {0, 0},
      heading: :up,
      known_panels: %{},
      default_color: :black
    }
    |> Map.merge(initial_state)
    |> run()
  end

  # def execute_instructions(state, [color, direction])

  def execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, [0, 0]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :left, position: update_position(position, :left)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, [1, 0]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :left, position: update_position(position, :left)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, [0, 0]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :down, position: update_position(position, :down)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, [1, 0]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :down, position: update_position(position, :down)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, [0, 0]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :right, position: update_position(position, :right)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, [1, 0]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :right, position: update_position(position, :right)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, [0, 0]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :up, position: update_position(position, :up)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, [1, 0]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :up, position: update_position(position, :up)}

  def execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, [0, 1]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :right, position: update_position(position, :right)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, [1, 1]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :right, position: update_position(position, :right)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, [0, 1]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :up, position: update_position(position, :up)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, [1, 1]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :up, position: update_position(position, :up)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, [0, 1]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :left, position: update_position(position, :left)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, [1, 1]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :left, position: update_position(position, :left)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, [0, 1]), do: %{state | known_panels: Map.put(panels, position, :black), heading: :down, position: update_position(position, :down)}
  def execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, [1, 1]), do: %{state | known_panels: Map.put(panels, position, :white), heading: :down, position: update_position(position, :down)}

  def update_position({x, y}, :up), do: {x, y - 1}
  def update_position({x, y}, :left), do: {x - 1, y}
  def update_position({x, y}, :down), do: {x, y + 1}
  def update_position({x, y}, :right), do: {x + 1, y}

  # def paint_panel(%{position: position, known_panels: panels} = state, 0), do: %{state | known_panels: Map.put(panels, position, :black)}
  # def paint_panel(%{position: position, known_panels: panels} = state, 1), do: %{state | known_panels: Map.put(panels, position, :white)}

  def read_instructions(%{output: agent} = state) do
    instructions =
      Agent.get_and_update(agent, fn buffer ->
        if Enum.count(buffer) >= 2 do
          Enum.split(buffer, 2)
        else
          {[], buffer}
        end
      end)
    if Enum.count(instructions) == 2 do
      {:ok, instructions, state}
    else
      {:blocked, state}
    end
  end

  def stop(%{vm: vm} = state) when not(is_nil(vm)) do
    {:halt, %{state: :stopped}} = Task.await(vm)
    stop(%{state | vm: nil})
  end

  def stop(%{output: agent} = state) when not(is_nil(agent)) do
    Agent.stop(agent)
    stop(%{state | output: nil})
  end

  def stop(state), do: state

  def write_camera(%{vm: vm} = state, :black) do
    send(vm.pid, 0)
    state
  end

  def write_camera(%{vm: vm} = state, :white) do
    send(vm.pid, 1)
    state
  end

  defp run(%{memory: nil}), do: {:error, "memory not initialized"}

  defp run(%{output: nil} = state) do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    run(%{state | output: agent})
  end

  defp run(%{vm: nil, memory: memory, output: agent} = state) do
    output_fn = fn value -> Agent.update(agent, fn buffer -> List.flatten([buffer, value]) end) end
    vm =
      Task.async(Interpreter, :initialize, [
        %{state: :running, memory: memory, output_fn: output_fn}
      ])
    {:ok, %{state | vm: vm}}
  end
end

defmodule AoC.Intcode.PaintingRobot do
  @moduledoc false

  use Task

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      position: {0, 0},
      heading: :up,
      known_panels: %{},
      default_color: :black,
      pending_color: nil,
      pending_direction: nil
    }
    |> Map.merge(initial_state)
    |> run()
  end

  defp run(%{state: :ready} = state) do
    receive do
      :start ->
        run(%{state | state: :running})

      :term ->
        {:halt, %{state | state: :term}}
    end
  end

  defp run(%{state: :running, pending_color: nil} = state) do
    state = read_camera(state)

    receive do
      :term ->
        {:halt, %{state | state: :term}}

      color ->
        run(%{state | pending_color: color})
    end
  end

  defp run(%{state: :running, pending_direction: nil} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      direction ->
        run(%{state | pending_direction: direction})
    end
  end

  defp run(%{state: :running, pending_color: color, pending_direction: direction} = state) do
    new_state = execute_instructions(state, {color, direction})
    run(%{new_state | pending_color: nil, pending_direction: nil})
  end

  defp execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, {0, 0}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :left, position: update_position(position, :left)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, {1, 0}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :left, position: update_position(position, :left)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, {0, 0}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :down, position: update_position(position, :down)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, {1, 0}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :down, position: update_position(position, :down)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, {0, 0}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :right, position: update_position(position, :right)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, {1, 0}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :right, position: update_position(position, :right)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, {0, 0}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :up, position: update_position(position, :up)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, {1, 0}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :up, position: update_position(position, :up)}

  defp execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, {0, 1}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :right, position: update_position(position, :right)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :up} = state, {1, 1}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :right, position: update_position(position, :right)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, {0, 1}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :up, position: update_position(position, :up)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :left} = state, {1, 1}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :up, position: update_position(position, :up)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, {0, 1}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :left, position: update_position(position, :left)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :down} = state, {1, 1}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :left, position: update_position(position, :left)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, {0, 1}), do: %{state | known_panels: Map.put(panels, position, :black), heading: :down, position: update_position(position, :down)}
  defp execute_instructions(%{known_panels: panels, position: position, heading: :right} = state, {1, 1}), do: %{state | known_panels: Map.put(panels, position, :white), heading: :down, position: update_position(position, :down)}

  defp read_camera(%{position: position, known_panels: panels, cpu: cpu} = state) do
    color = Map.get(panels, position, state.default_color)
    IO.puts("ROBOT: color at #{inspect position} is #{color}")
    send(cpu.pid, color)
    state
  end

  defp update_position({x, y}, :up), do: {x, y - 1}
  defp update_position({x, y}, :left), do: {x - 1, y}
  defp update_position({x, y}, :down), do: {x, y + 1}
  defp update_position({x, y}, :right), do: {x + 1, y}
end

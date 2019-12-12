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
      pending_direction: nil,
      trace: false
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

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :up} = state,
         {0, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :left,
           position: update_position(position, :left, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :up} = state,
         {1, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :left,
           position: update_position(position, :left, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :left} = state,
         {0, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :down,
           position: update_position(position, :down, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :left} = state,
         {1, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :down,
           position: update_position(position, :down, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :down} = state,
         {0, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :right,
           position: update_position(position, :right, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :down} = state,
         {1, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :right,
           position: update_position(position, :right, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :right} = state,
         {0, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :up,
           position: update_position(position, :up, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :right} = state,
         {1, 0}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :up,
           position: update_position(position, :up, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :up} = state,
         {0, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :right,
           position: update_position(position, :right, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :up} = state,
         {1, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :right,
           position: update_position(position, :right, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :left} = state,
         {0, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :up,
           position: update_position(position, :up, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :left} = state,
         {1, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :up,
           position: update_position(position, :up, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :down} = state,
         {0, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :left,
           position: update_position(position, :left, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :down} = state,
         {1, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :left,
           position: update_position(position, :left, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :right} = state,
         {0, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :black, state.trace),
           heading: :down,
           position: update_position(position, :down, state.trace)
       }

  defp execute_instructions(
         %{known_panels: panels, position: position, heading: :right} = state,
         {1, 1}
       ),
       do: %{
         state
         | known_panels: paint_panel(panels, position, :white, state.trace),
           heading: :down,
           position: update_position(position, :down, state.trace)
       }

  defp paint_panel(panels, position, color, true) do
    if Map.has_key?(panels, position) do
      IO.puts("repainting #{inspect(position)} #{inspect(color)}")
    else
      IO.puts("painting   #{inspect(position)} #{inspect(color)}")
    end

    paint_panel(panels, position, color, false)
  end

  defp paint_panel(panels, position, color, _), do: Map.put(panels, position, color)

  defp read_camera(%{position: position, known_panels: panels, cpu: cpu} = state) do
    color_number =
      panels
      |> Map.get(position, state.default_color)
      |> convert_color_to_number()

    send(cpu.pid, color_number)
    state
  end

  defp convert_color_to_number(:black), do: 0
  defp convert_color_to_number(:white), do: 1

  defp update_position(position, :up, true) do
    IO.puts("facing up and moving forward")
    update_position(position, :up, false)
  end

  defp update_position(position, :left, true) do
    IO.puts("facing left and moving forward")
    update_position(position, :left, false)
  end

  defp update_position(position, :down, true) do
    IO.puts("facing down and moving forward")
    update_position(position, :down, false)
  end

  defp update_position(position, :right, true) do
    IO.puts("facing right and moving forward")
    update_position(position, :right, false)
  end

  defp update_position({x, y}, :up, _), do: {x, y - 1}
  defp update_position({x, y}, :left, _), do: {x - 1, y}
  defp update_position({x, y}, :down, _), do: {x, y + 1}
  defp update_position({x, y}, :right, _), do: {x + 1, y}
end

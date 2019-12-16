defmodule AoC.Intcode.RepairDroid do
  @moduledoc false

  use Task

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      map: Graph.new(),
      position: {0, 0},
      heading: :north,
      trace: false
    }
    |> Map.merge(initial_state)
    |> run()
  end

  def position_to_string({x, y}), do: "{#{x}, #{y}}"

  defp run(%{state: :ready} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      :start ->
        state
        |> Map.put(:state, :running)
        |> run()

      :movement_req ->
        # not a valid movement
        send(state.cpu, 0)
        run(state)
    end
  end

  defp run(%{state: :running} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      :move_req ->
        state
        |> send_move()
        |> run()

      {:status, status} ->
        state
        |> update_map(status)
        |> run()
    end
  end

  defp run(%{state: :found} = state) do
    {:halt, %{state | state: :term}}
  end

  defp direction_to_cmd(:north), do: 1
  defp direction_to_cmd(:south), do: 2
  defp direction_to_cmd(:west), do: 3
  defp direction_to_cmd(:east), do: 4

  defp position_in_direction({x, y}, :north), do: {x, y - 1}
  defp position_in_direction({x, y}, :south), do: {x, y + 1}
  defp position_in_direction({x, y}, :west), do: {x - 1, y}
  defp position_in_direction({x, y}, :east), do: {x + 1, y}

  defp rotate_cw(%{heading: :north} = state), do: %{state | heading: :east}
  defp rotate_cw(%{heading: :east} = state), do: %{state | heading: :south}
  defp rotate_cw(%{heading: :south} = state), do: %{state | heading: :west}
  defp rotate_cw(%{heading: :west} = state), do: %{state | heading: :north}

  defp rotate_ccw(%{heading: :north} = state), do: %{state | heading: :west}
  defp rotate_ccw(%{heading: :west} = state), do: %{state | heading: :south}
  defp rotate_ccw(%{heading: :south} = state), do: %{state | heading: :east}
  defp rotate_ccw(%{heading: :east} = state), do: %{state | heading: :north}

  defp send_move(%{cpu: cpu, heading: direction} = state) do
    send(cpu.pid, direction_to_cmd(direction))
    state
  end

  defp trace(%{trace: false} = state, _), do: state

  defp trace(%{trace: true} = state, msg) do
    IO.puts(msg)
    state
  end

  # could not move
  defp update_map(state, 0) do
    state
    |> trace("could not move #{inspect(state.heading)}")
    |> rotate_cw()
  end

  # moved
  defp update_map(state, 1) do
    state = update_position(state)

    state
    |> trace("moved #{inspect(state.heading)} to #{position_to_string(state.position)}")
    |> rotate_ccw()
  end

  # found target
  defp update_map(state, 2) do
    state = update_position(state)

    trace(
      state,
      "moved #{inspect(state.heading)} to #{position_to_string(state.position)}; found target"
    )

    %{state | state: :found}
  end

  defp update_position(%{map: map, position: position, heading: heading} = state) do
    new_position = position_in_direction(position, heading)

    updated_map =
      map
      |> Graph.add_edge(position, new_position)
      |> Graph.add_edge(new_position, position)

    trace(
      state,
      "adding edge between #{position_to_string(position)} and #{position_to_string(new_position)}"
    )

    %{state | map: updated_map, position: new_position}
  end
end

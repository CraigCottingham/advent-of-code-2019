defmodule AoC.Intcode.RepairDroid do
  @moduledoc false

  use Task

  alias IO.ANSI

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      map: Graph.new(),
      position: {0, 0},
      target_position: nil,
      known_locations: %{{0, 0} => 1},
      heading: :north,
      trace: false
    }
    |> Map.merge(initial_state)
    |> run()
  end

  def position_to_string({x, y}), do: "{#{x}, #{y}}"

  defp run(%{state: :ready, trace: trace} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      :start ->
        if trace == :render, do: ANSI.clear() |> IO.write()

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
        %{known_locations: known_locations} = new_state = update_map(state, status)

        if !is_nil(new_state.target_position) &&
             Enum.all?(Map.values(known_locations), fn value -> !is_nil(value) end) do
          {:halt, %{new_state | state: :term}}
        else
          run(new_state)
        end
    end
  end

  defp run(%{state: :found, trace: trace} = state) do
    if trace == :render, do: ANSI.cursor(44, 0) |> IO.write()
    {:halt, %{state | state: :term}}
  end

  defp direction_to_cmd(:north), do: 1
  defp direction_to_cmd(:south), do: 2
  defp direction_to_cmd(:west), do: 3
  defp direction_to_cmd(:east), do: 4

  defp location_type_to_str(nil), do: "."
  defp location_type_to_str(0), do: "█"
  defp location_type_to_str(1), do: " "
  defp location_type_to_str(2), do: "o"

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

  defp trace(
         %{known_locations: known_locations, position: {_me_x, _me_y}, trace: :render} = state,
         _
       ) do
    if ANSI.enabled?() do
      known_locations
      |> Enum.each(fn {{x, y}, type} ->
        ANSI.cursor(y + 25, x + 25) |> IO.write()

        type
        |> location_type_to_str()
        |> IO.write()
      end)

      # ANSI.cursor(me_y + 25, me_x + 25) |> IO.write()
      # IO.write("*")
    end

    state
  end

  # could not move
  defp update_map(
         %{known_locations: known_locations, position: position, heading: heading} = state,
         0
       ) do
    state
    |> Map.put(
      :known_locations,
      Map.put(known_locations, position_in_direction(position, heading), 0)
    )
    |> trace("could not move #{inspect(heading)}")
    |> rotate_cw()
  end

  # moved
  defp update_map(state, 1) do
    state = update_position(state)

    state
    |> Map.put(:known_locations, Map.put(state.known_locations, state.position, 1))
    |> trace("moved #{inspect(state.heading)} to #{position_to_string(state.position)}")
    |> update_surroundings()
    |> rotate_ccw()
  end

  # found target
  defp update_map(state, 2) do
    state = update_position(state)

    state
    |> Map.put(:known_locations, Map.put(state.known_locations, state.position, 2))
    |> Map.put(:target_position, state.position)
    |> trace("moved #{inspect(state.heading)} to #{position_to_string(state.position)}")
    |> trace("found target")
    |> update_surroundings()
    |> rotate_ccw()
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

  defp update_surroundings(%{known_locations: known_locations, position: position} = state) do
    updated_known_locations =
      known_locations
      |> Map.put_new(position_in_direction(position, :north), nil)
      |> Map.put_new(position_in_direction(position, :south), nil)
      |> Map.put_new(position_in_direction(position, :west), nil)
      |> Map.put_new(position_in_direction(position, :east), nil)

    %{state | known_locations: updated_known_locations}
  end
end

defmodule AoC.Intcode.Arcade do
  @moduledoc false

  use Task

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      tiles: %{},
      pending_x: nil,
      pending_y: nil,
      pending_tile: nil,
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

  defp run(%{state: :running, pending_x: nil} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      x ->
        run(%{state | pending_x: x})
    end
  end

  defp run(%{state: :running, pending_y: nil} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      y ->
        run(%{state | pending_y: y})
    end
  end

  defp run(%{state: :running, pending_tile: nil} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      tile ->
        run(%{state | pending_tile: tile})
    end
  end

  defp run(%{state: :running, pending_x: x, pending_y: y, pending_tile: tile} = state) do
    new_state = render_tile(state, {x, y, tile})
    run(%{new_state | pending_x: nil, pending_y: nil, pending_tile: nil})
  end

  defp render_tile(%{tiles: tiles} = state, {x, y, 0}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :empty)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 1}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :wall)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 2}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :block)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 3}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :paddle)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 4}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :ball)}
end

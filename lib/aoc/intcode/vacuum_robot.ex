defmodule AoC.Intcode.VacuumRobot do
  @moduledoc false

  use Task

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      view: [],
      current_line: [],
      trace: false
    }
    |> Map.merge(initial_state)
    |> run()
  end

  defp run(%{state: :ready} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      :start ->
        state
        |> Map.put(:state, :running)
        |> run()
    end
  end

  defp run(%{state: :running, view: view, current_line: line} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      {:pixel, value} ->
        new_state =
          case value do
            10 ->
              %{state | view: [line] ++ view, current_line: []}

            _ ->
              %{state | current_line: [value] ++ line}
          end

        run(new_state)
    end
  end
end

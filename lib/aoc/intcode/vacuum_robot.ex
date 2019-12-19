defmodule AoC.Intcode.VacuumRobot do
  @moduledoc false

  use Task

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      view: [],
      current_line: [],
      programs: [],
      dust_amount: 0,
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

      :send_program_char ->
        # not a valid program character
        send(state.cpu.pid, 0)
        run(state)
    end
  end

  defp run(%{state: :running, view: view, current_line: line, programs: programs} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

      :send_program_char when programs == [] ->
        # not a valid program character
        send(state.cpu.pid, 0)
        run(state)

      :send_program_char ->
        [c | rest] = programs
        send(state.cpu.pid, c)
        run(%{state | programs: rest})

      {:pixel, value} ->
        new_state =
          case value do
            10 ->
              %{state | view: [line] ++ view, current_line: []}

            _ ->
              %{state | current_line: [value] ++ line}
          end

        run(new_state)

      value ->
        # IO.write <<value::utf8>>
        run(%{state | dust_amount: value})
    end
  end
end

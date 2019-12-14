defmodule AoC.Intcode.Arcade do
  @moduledoc false

  use Task

  alias IO.ANSI

  @tick_interval div(1_000, 15)

  def initialize(initial_state \\ %{}) do
    %{
      state: :ready,
      cpu: nil,
      score: -1,
      tiles: %{},
      ball_position: nil,
      paddle_position: nil,
      render_screen: false,
      pending_x: nil,
      pending_y: nil,
      pending_tile: nil,
      timer: nil,
      trace: false
    }
    |> Map.merge(initial_state)
    |> run()
  end

  defp run(%{state: :ready} = state) do
    receive do
      :term ->
        if state.render_screen, do: ANSI.clear() |> IO.write()
        {:halt, %{state | state: :term}}

      :start ->
        if state.render_screen, do: ANSI.clear() |> IO.write()

        state
        |> schedule_next_tick()
        |> Map.put(:state, :running)
        |> run()

      :joystick_req ->
        send(state.cpu, 0)
        run(state)
    end
  end

  defp run(%{state: :running, pending_x: nil} = state) do
    receive do
      :term ->
        if state.render_screen, do: ANSI.clear() |> IO.write()
        {:halt, %{state | state: :term}}

      :tick ->
        state
        |> render_screen()
        |> schedule_next_tick()
        |> run()

      :joystick_req ->
        send_joystick_position(state)
        run(state)

      x ->
        run(%{state | pending_x: x})
    end
  end

  defp run(%{state: :running, pending_y: nil} = state) do
    receive do
      :term ->
        if state.render_screen, do: ANSI.clear() |> IO.write()
        {:halt, %{state | state: :term}}

      :tick ->
        state
        |> render_screen()
        |> schedule_next_tick()
        |> run()

      :joystick_req ->
        send_joystick_position(state)
        run(state)

      y ->
        run(%{state | pending_y: y})
    end
  end

  defp run(%{state: :running, pending_tile: nil} = state) do
    receive do
      :term ->
        if state.render_screen, do: ANSI.clear() |> IO.write()
        {:halt, %{state | state: :term}}

      :tick ->
        state
        |> render_screen()
        |> schedule_next_tick()
        |> run()

      :joystick_req ->
        send_joystick_position(state)
        run(state)

      tile ->
        run(%{state | pending_tile: tile})
    end
  end

  defp run(%{state: :running, pending_x: x, pending_y: y, pending_tile: tile} = state) do
    new_state = render_tile(state, {x, y, tile})
    run(%{new_state | pending_x: nil, pending_y: nil, pending_tile: nil})
  end

  defp render_screen(%{render_screen: false} = state), do: state

  defp render_screen(%{tiles: tiles, score: score} = state) do
    if ANSI.enabled?() do
      tiles
      |> Enum.each(fn {{x, y}, tile} ->
        char =
          case tile do
            :empty -> " "
            :wall -> "W"
            :block -> "B"
            :paddle -> "_"
            :ball -> "o"
          end

        ANSI.cursor(y + 5, x + 5) |> IO.write()
        IO.write(char)
      end)

      ANSI.home() |> IO.write()
      IO.write("Score: #{score}")

      Process.sleep(@tick_interval)

      state
    else
      %{state | render_screen: false}
    end
  end

  defp render_tile(state, {-1, _, score}), do: %{state | score: score}

  defp render_tile(%{tiles: tiles} = state, {x, y, 0}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :empty)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 1}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :wall)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 2}),
    do: %{state | tiles: Map.put(tiles, {x, y}, :block)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 3}),
    do: %{state | paddle_position: {x, y}, tiles: Map.put(tiles, {x, y}, :paddle)}

  defp render_tile(%{tiles: tiles} = state, {x, y, 4}) do
    # send(self(), :tick)
    %{state | ball_position: {x, y}, tiles: Map.put(tiles, {x, y}, :ball)}
  end

  defp schedule_next_tick(state) do
    timer = Process.send_after(self(), :tick, @tick_interval)
    %{state | timer: timer}
  end

  defp send_joystick_position(%{
         cpu: cpu,
         ball_position: ball_position,
         paddle_position: paddle_position
       })
       when is_nil(ball_position) or is_nil(paddle_position),
       do: send(cpu.pid, 0)

  defp send_joystick_position(%{
         cpu: cpu,
         ball_position: {ball_x, _},
         paddle_position: {paddle_x, _}
       })
       when ball_x < paddle_x,
       do: send(cpu.pid, -1)

  defp send_joystick_position(%{
         cpu: cpu,
         ball_position: {ball_x, _},
         paddle_position: {paddle_x, _}
       })
       when ball_x > paddle_x,
       do: send(cpu.pid, 1)

  defp send_joystick_position(%{cpu: cpu}), do: send(cpu.pid, 0)
end

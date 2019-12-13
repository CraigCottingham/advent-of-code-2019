defmodule AoC.Intcode.Arcade do
  @moduledoc false

  use Task

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
        run(%{state | state: :running})

      :joystick_req ->
        send(state.cpu, 0)
        run(state)
    end
  end

  defp run(%{state: :running, pending_x: nil} = state) do
    receive do
      :term ->
        {:halt, %{state | state: :term}}

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
        {:halt, %{state | state: :term}}

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
        {:halt, %{state | state: :term}}

      :joystick_req ->
        send_joystick_position(state)
        run(state)

      tile ->
        run(%{state | pending_tile: tile})
    end
  end

  defp run(%{state: :running, pending_x: x, pending_y: y, pending_tile: tile} = state) do
    new_state =
      state
      |> render_tile({x, y, tile})
      |> render_screen()

    run(%{new_state | pending_x: nil, pending_y: nil, pending_tile: nil})
  end

  defp render_screen(%{render_screen: false} = state), do: state

  defp render_screen(
         %{score: score, ball_position: ball_pos, paddle_position: paddle_pos} = state
       ) do
    IO.puts("**********")
    IO.puts("Score:  #{score}")
    IO.puts("Ball:   #{inspect(ball_pos)}")
    IO.puts("Paddle: #{inspect(paddle_pos)}")
    IO.puts("Blocks: #{count_blocks(state)}")
    state
  end

  defp count_blocks(%{tiles: tiles}) do
    tiles
    |> Enum.filter(fn {_, value} -> value == :block end)
    |> Enum.count()
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

  defp render_tile(%{tiles: tiles} = state, {x, y, 4}),
    do: %{state | ball_position: {x, y}, tiles: Map.put(tiles, {x, y}, :ball)}

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

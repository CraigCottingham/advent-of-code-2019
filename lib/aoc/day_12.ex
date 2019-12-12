defmodule AoC.Day12 do
  @moduledoc false

  def part_1 do
    initial_states =
      "data/day12-input.txt"
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> parse_input_data()
      |> Enum.map(&initialize_moon/1)

    1..1000
    |> Enum.reduce(initial_states, fn _, states -> step(states) end)
    |> total_energy()
  end

  def part_2 do
  end

  def apply_gravity_vector(state1, state2),
    do: Enum.reduce([:x, :y, :z], state1, &apply_gravity_axis(&2, state2, &1))

  def apply_gravity(vec, others), do: Enum.reduce(others, vec, &apply_gravity_vector(&2, &1))

  def apply_velocity({{p_x, p_y, p_z}, {v_x, v_y, v_z} = v}),
    do: {{p_x + v_x, p_y + v_y, p_z + v_z}, v}

  def energy({p, v}), do: energy_vector(p) * energy_vector(v)

  def initialize_moon(position), do: {position, {0, 0, 0}}

  def parse_input_data(lines), do: Enum.map(lines, &parse_line/1)

  def step(states) do
    states
    |> Enum.map(fn state ->
      others = List.delete(states, state)

      state
      |> apply_gravity(others)
      |> apply_velocity
    end)
  end

  def total_energy(states) do
    states
    |> Enum.map(&energy/1)
    |> Enum.sum()
  end

  defp apply_gravity_axis({{p1_x, _, _} = p1, {v1_x, v1_y, v1_z}}, {{p2_x, _, _}, _}, :x)
       when p1_x < p2_x,
       do: {p1, {v1_x + 1, v1_y, v1_z}}

  defp apply_gravity_axis({{p1_x, _, _} = p1, {v1_x, v1_y, v1_z}}, {{p2_x, _, _}, _}, :x)
       when p1_x > p2_x,
       do: {p1, {v1_x - 1, v1_y, v1_z}}

  defp apply_gravity_axis({{_, p1_y, _} = p1, {v1_x, v1_y, v1_z}}, {{_, p2_y, _}, _}, :y)
       when p1_y < p2_y,
       do: {p1, {v1_x, v1_y + 1, v1_z}}

  defp apply_gravity_axis({{_, p1_y, _} = p1, {v1_x, v1_y, v1_z}}, {{_, p2_y, _}, _}, :y)
       when p1_y > p2_y,
       do: {p1, {v1_x, v1_y - 1, v1_z}}

  defp apply_gravity_axis({{_, _, p1_z} = p1, {v1_x, v1_y, v1_z}}, {{_, _, p2_z}, _}, :z)
       when p1_z < p2_z,
       do: {p1, {v1_x, v1_y, v1_z + 1}}

  defp apply_gravity_axis({{_, _, p1_z} = p1, {v1_x, v1_y, v1_z}}, {{_, _, p2_z}, _}, :z)
       when p1_z > p2_z,
       do: {p1, {v1_x, v1_y, v1_z - 1}}

  defp apply_gravity_axis({p1, v1}, _, _), do: {p1, v1}

  defp energy_vector(v), do: Tuple.to_list(v) |> Enum.map(&abs/1) |> Enum.sum()

  defp parse_line(line) do
    # <x=-1, y=0, z=2>
    line
    |> String.trim_leading("<")
    |> String.trim_trailing(">")
    |> String.split(~r(\s*,\s*))
    # ["x=-1", "y=0", "z=2"]
    |> Enum.map(&String.replace(&1, ~r/^[^=]+=/, ""))
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

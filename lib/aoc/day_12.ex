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
    "data/day12-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> parse_input_data()
    |> Enum.map(&initialize_moon/1)
    |> cycle_length()
  end

  def apply_gravity_vector(state1, state2),
    do: Enum.reduce([:x, :y, :z], state1, &apply_gravity_axis(&2, state2, &1))

  def apply_gravity(vec, others), do: Enum.reduce(others, vec, &apply_gravity_vector(&2, &1))

  def apply_velocity({{p_x, p_y, p_z}, {v_x, v_y, v_z} = v}),
    do: {{p_x + v_x, p_y + v_y, p_z + v_z}, v}

  def cycle_length(initial_states) do
    new_states = AoC.Day12.step(initial_states)

    cycle_length_per_axis(new_states, :x, 1)
    |> Math.lcm(cycle_length_per_axis(new_states, :y, 1))
    |> Math.lcm(cycle_length_per_axis(new_states, :z, 1))
    |> Kernel.*(2)
  end

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

  def until_zero_energy(_, 0, counter), do: counter * 2

  def until_zero_energy(states, _, counter) do
    new_states = AoC.Day12.step(states)
    new_energy = AoC.Day12.total_energy(new_states)
    until_zero_energy(new_states, new_energy, counter + 1)
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

  defp cycle_length_per_axis(states, :x, counter) do
    all_zeros =
      states
      |> Enum.map(fn {_, {velocity, _, _}} -> velocity end)
      |> Enum.all?(fn value -> value == 0 end)

    if all_zeros do
      counter
    else
      new_states = AoC.Day12.step(states)
      cycle_length_per_axis(new_states, :x, counter + 1)
    end
  end

  defp cycle_length_per_axis(states, :y, counter) do
    all_zeros =
      states
      |> Enum.map(fn {_, {_, velocity, _}} -> velocity end)
      |> Enum.all?(fn value -> value == 0 end)

    if all_zeros do
      counter
    else
      new_states = AoC.Day12.step(states)
      cycle_length_per_axis(new_states, :y, counter + 1)
    end
  end

  defp cycle_length_per_axis(states, :z, counter) do
    all_zeros =
      states
      |> Enum.map(fn {_, {_, _, velocity}} -> velocity end)
      |> Enum.all?(fn value -> value == 0 end)

    if all_zeros do
      counter
    else
      new_states = AoC.Day12.step(states)
      cycle_length_per_axis(new_states, :z, counter + 1)
    end
  end

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

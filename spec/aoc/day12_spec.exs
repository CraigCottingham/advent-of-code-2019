defmodule AoC.Day12.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "parses input data" do
      data = [
        "<x=-1, y=0, z=2>",
        "<x=2, y=-10, z=-7>",
        "<x=4, y=-8, z=8>",
        "<x=3, y=5, z=-1>"
      ]

      positions = AoC.Day12.parse_input_data(data)

      expect(positions)
      |> to(
        eq([
          {-1, 0, 2},
          {2, -10, -7},
          {4, -8, 8},
          {3, 5, -1}
        ])
      )

      expect(Enum.map(positions, &AoC.Day12.initialize_moon/1))
      |> to(
        eq([
          {{-1, 0, 2}, {0, 0, 0}},
          {{2, -10, -7}, {0, 0, 0}},
          {{4, -8, 8}, {0, 0, 0}},
          {{3, 5, -1}, {0, 0, 0}}
        ])
      )
    end

    it "calculates total energy after 100 steps" do
      initial_states =
        [
          "<x=-8, y=-10, z=0>",
          "<x=5, y=5, z=10>",
          "<x=2, y=-7, z=3>",
          "<x=9, y=-8, z=-3>"
        ]
        |> AoC.Day12.parse_input_data()
        |> Enum.map(&AoC.Day12.initialize_moon/1)

      moons =
        1..100
        |> Enum.reduce(initial_states, fn _, states -> AoC.Day12.step(states) end)

      expect(moons)
      |> to(
        eq([
          {{8, -12, -9}, {-7, 3, 0}},
          {{13, 16, -3}, {3, -11, -5}},
          {{-29, -11, -1}, {-3, 7, 4}},
          {{16, -13, 23}, {7, 1, 1}}
        ])
      )

      expect(AoC.Day12.total_energy(moons)) |> to(eq(1940))
    end

    it "looks for a return to the original state, the short version" do
      initial_states =
        [
          "<x=-1, y=0, z=2>",
          "<x=2, y=-10, z=-7>",
          "<x=4, y=-8, z=8>",
          "<x=3, y=5, z=-1>"
        ]
        |> AoC.Day12.parse_input_data()
        |> Enum.map(&AoC.Day12.initialize_moon/1)

      new_states = AoC.Day12.step(initial_states)
      new_energy = AoC.Day12.total_energy(new_states)

      expect(AoC.Day12.until_zero_energy(new_states, new_energy, 1)) |> to(eq(2772))
    end
  end

  example_group "apply_gravity_vector/2" do
    it do
      moon_a = {{-1, 0, 2}, {0, 0, 0}}
      moon_b = {{2, -10, -7}, {0, 0, 0}}

      expect(AoC.Day12.apply_gravity_vector(moon_a, moon_b)) |> to(eq({{-1, 0, 2}, {1, -1, -1}}))
    end
  end

  example_group "apply_gravity/2" do
    it do
      moon_a = {{-1, 0, 2}, {0, 0, 0}}
      moon_b = {{2, -10, -7}, {0, 0, 0}}
      moon_c = {{4, -8, 8}, {0, 0, 0}}
      moon_d = {{3, 5, -1}, {0, 0, 0}}

      expect(AoC.Day12.apply_gravity(moon_a, [moon_b, moon_c, moon_d]))
      |> to(eq({{-1, 0, 2}, {3, -1, -1}}))
    end
  end

  example_group "apply_velocity/1" do
    it do
      expect(AoC.Day12.apply_velocity({{-1, 0, 2}, {3, -1, -1}}))
      |> to(eq({{2, -1, 1}, {3, -1, -1}}))
    end
  end

  example_group "cycle_length/1" do
    it do
      initial_states = [
        {{-1, 0, 2}, {0, 0, 0}},
        {{2, -10, -7}, {0, 0, 0}},
        {{4, -8, 8}, {0, 0, 0}},
        {{3, 5, -1}, {0, 0, 0}}
      ]

      expect(AoC.Day12.cycle_length(initial_states)) |> to(eq(2772))
    end
  end

  example_group "energy/1" do
    it do
      expect(AoC.Day12.energy({{2, 1, -3}, {-3, -2, 1}})) |> to(eq(36))
    end
  end

  example_group "total_energy/1" do
    it do
      moons = [
        {{2, 1, -3}, {-3, -2, 1}},
        {{1, -8, 0}, {-1, 1, 3}},
        {{3, -6, 1}, {3, 2, -3}},
        {{2, 0, 4}, {1, -1, -1}}
      ]

      expect(AoC.Day12.total_energy(moons)) |> to(eq(179))
    end
  end

  example_group "step/1" do
    it do
      moons = [
        {{-1, 0, 2}, {0, 0, 0}},
        {{2, -10, -7}, {0, 0, 0}},
        {{4, -8, 8}, {0, 0, 0}},
        {{3, 5, -1}, {0, 0, 0}}
      ]

      # step 1
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{2, -1, 1}, {3, -1, -1}},
          {{3, -7, -4}, {1, 3, 3}},
          {{1, -7, 5}, {-3, 1, -3}},
          {{2, 2, 0}, {-1, -3, 1}}
        ])
      )

      # step 2
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{5, -3, -1}, {3, -2, -2}},
          {{1, -2, 2}, {-2, 5, 6}},
          {{1, -4, -1}, {0, 3, -6}},
          {{1, -4, 2}, {-1, -6, 2}}
        ])
      )

      # step 3
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{5, -6, -1}, {0, -3, 0}},
          {{0, 0, 6}, {-1, 2, 4}},
          {{2, 1, -5}, {1, 5, -4}},
          {{1, -8, 2}, {0, -4, 0}}
        ])
      )

      # step 4
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{2, -8, 0}, {-3, -2, 1}},
          {{2, 1, 7}, {2, 1, 1}},
          {{2, 3, -6}, {0, 2, -1}},
          {{2, -9, 1}, {1, -1, -1}}
        ])
      )

      # step 5
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{-1, -9, 2}, {-3, -1, 2}},
          {{4, 1, 5}, {2, 0, -2}},
          {{2, 2, -4}, {0, -1, 2}},
          {{3, -7, -1}, {1, 2, -2}}
        ])
      )

      # step 6
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{-1, -7, 3}, {0, 2, 1}},
          {{3, 0, 0}, {-1, -1, -5}},
          {{3, -2, 1}, {1, -4, 5}},
          {{3, -4, -2}, {0, 3, -1}}
        ])
      )

      # step 7
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{2, -2, 1}, {3, 5, -2}},
          {{1, -4, -4}, {-2, -4, -4}},
          {{3, -7, 5}, {0, -5, 4}},
          {{2, 0, 0}, {-1, 4, 2}}
        ])
      )

      # step 8
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{5, 2, -2}, {3, 4, -3}},
          {{2, -7, -5}, {1, -3, -1}},
          {{0, -9, 6}, {-3, -2, 1}},
          {{1, 1, 3}, {-1, 1, 3}}
        ])
      )

      # step 9
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{5, 3, -4}, {0, 1, -2}},
          {{2, -9, -3}, {0, -2, 2}},
          {{0, -8, 4}, {0, 1, -2}},
          {{1, 1, 5}, {0, 0, 2}}
        ])
      )

      # step 10
      moons = AoC.Day12.step(moons)

      expect(moons)
      |> to(
        eq([
          {{2, 1, -3}, {-3, -2, 1}},
          {{1, -8, 0}, {-1, 1, 3}},
          {{3, -6, 1}, {3, 2, -3}},
          {{2, 0, 4}, {1, -1, -1}}
        ])
      )
    end
  end
end

defmodule AoC.Day10.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
  end

  example_group "angle/2" do
    it("positive X axis", do: expect(AoC.Day10.angle({0, 0}, {0, 1})) |> to(eq(0)))
    it("quadrant I", do: expect(AoC.Day10.angle({0, 0}, {-1, 1})) |> to(eq(Math.pi() / 4)))
    it("positive Y axis", do: expect(AoC.Day10.angle({0, 0}, {-1, 0})) |> to(eq(Math.pi() / 2)))
    it("quadrant II", do: expect(AoC.Day10.angle({0, 0}, {-1, -1})) |> to(eq(Math.pi() * 3 / 4)))
    it("negative X axis", do: expect(AoC.Day10.angle({0, 0}, {0, -1})) |> to(eq(Math.pi())))
    it("quadrant III", do: expect(AoC.Day10.angle({0, 0}, {1, -1})) |> to(eq(Math.pi() * 5 / 4)))
    it("negative Y axis", do: expect(AoC.Day10.angle({0, 0}, {1, 0})) |> to(eq(Math.pi() * 3 / 2)))
    it("quadrant IV", do: expect(AoC.Day10.angle({0, 0}, {1, 1})) |> to(eq(Math.pi() * 7 / 4)))
  end

  example_group "filter/2" do
    it do
      map_data = [".#..#", ".....", "#####", "....#", "...##"]
      m = AoC.Day10.map_data_to_matrix(map_data)

      expect(AoC.Day10.filter(m, fn {_, value} -> value == 1 end))
      |> to(eq([{0, 1}, {0, 4}, {2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4}, {3, 4}, {4, 3}, {4, 4}]))
    end
  end

  example_group "map_data_to_matrix/1" do
    it do
      map_data = [".#..#", ".....", "#####", "....#", "...##"]
      m = AoC.Day10.map_data_to_matrix(map_data)

      expect(m.rows) |> to(eq(5))
      expect(m.columns) |> to(eq(5))

      expect(Max.to_list_of_lists(m))
      |> to(
        eq([[0, 1, 0, 0, 1], [0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [0, 0, 0, 0, 1], [0, 0, 0, 1, 1]])
      )
    end
  end

  example_group "max_detected/1" do
    it do
      expect(AoC.Day10.max_detected([".#..#", ".....", "#####", "....#", "...##"])) |> to(eq(8))

      expect(
        AoC.Day10.max_detected([
          "......#.#.",
          "#..#.#....",
          "..#######.",
          ".#.#.###..",
          ".#..#.....",
          "..#....#.#",
          "#..#....#.",
          ".##.#..###",
          "##...#..#.",
          ".#....####"
        ])
      )
      |> to(eq(33))

      expect(
        AoC.Day10.max_detected([
          "#.#...#.#.",
          ".###....#.",
          ".#....#...",
          "##.#.#.#.#",
          "....#.#.#.",
          ".##..###.#",
          "..#...##..",
          "..##....##",
          "......#...",
          ".####.###."
        ])
      )
      |> to(eq(35))

      expect(
        AoC.Day10.max_detected([
          ".#..#..###",
          "####.###.#",
          "....###.#.",
          "..###.##.#",
          "##.##.#.#.",
          "....###..#",
          "..#.#..#.#",
          "#..#.#.###",
          ".##...##.#",
          ".....#.#.."
        ])
      )
      |> to(eq(41))

      expect(
        AoC.Day10.max_detected([
          ".#..##.###...#######",
          "##.############..##.",
          ".#.######.########.#",
          ".###.#######.####.#.",
          "#####.##.#.##.###.##",
          "..#####..#.#########",
          "####################",
          "#.####....###.#.#.##",
          "##.#################",
          "#####.##.###..####..",
          "..######..##.#######",
          "####.##.####...##..#",
          ".#####..#.######.###",
          "##...#.##########...",
          "#.##########.#######",
          ".####.#.###.###.#.##",
          "....##.##.###..#####",
          ".#.#.###########.###",
          "#.#.#.#####.####.###",
          "###.##.####.##.#..##"
        ])
      )
      |> to(eq(210))
    end
  end

  example_group "position_angles/2" do
    it do
      this_position = {2, 4}
      other_positions = [{0, 1}, {0, 4}, {2, 0}, {2, 1}, {2, 2}, {2, 3}, {3, 4}, {4, 3}, {4, 4}]

      expect(AoC.Day10.position_angles(this_position, other_positions))
      |> to(
        eq([
          {{0, 1}, 2.5535900500422257},
          {{0, 4}, Math.pi() / 2},
          {{2, 0}, Math.pi()},
          {{2, 1}, Math.pi()},
          {{2, 2}, Math.pi()},
          {{2, 3}, Math.pi()},
          {{3, 4}, Math.pi() * 3 / 2},
          {{4, 3}, 4.2487413713838835},
          {{4, 4}, Math.pi() * 3 / 2}
        ])
      )
    end
  end

  example_group "detected_count" do
    it do
      all_positions = [
        {0, 1},
        {0, 4},
        {2, 0},
        {2, 1},
        {2, 2},
        {2, 3},
        {2, 4},
        {3, 4},
        {4, 3},
        {4, 4}
      ]

      expect(AoC.Day10.detected_count({0, 1}, List.delete(all_positions, {0, 1}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({0, 4}, List.delete(all_positions, {0, 4}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({2, 0}, List.delete(all_positions, {2, 0}))) |> to(eq(6))
      expect(AoC.Day10.detected_count({2, 1}, List.delete(all_positions, {2, 1}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({2, 2}, List.delete(all_positions, {2, 2}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({2, 3}, List.delete(all_positions, {2, 3}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({2, 4}, List.delete(all_positions, {2, 4}))) |> to(eq(5))
      expect(AoC.Day10.detected_count({3, 4}, List.delete(all_positions, {3, 4}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({4, 3}, List.delete(all_positions, {4, 3}))) |> to(eq(8))
      expect(AoC.Day10.detected_count({4, 4}, List.delete(all_positions, {4, 4}))) |> to(eq(7))
    end
  end
end

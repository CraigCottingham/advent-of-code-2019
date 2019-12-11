defmodule AoC.Day10.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests a small example" do
      expect(
        AoC.Day10.zap_asteroids(
          [
            ".#....#####...#..",
            "##...##.#####..##",
            "##...#...#.#####.",
            "..#.....X...###..",
            "..#.#.....#....##"
          ],
          {8, 3}
        )
      )
      |> to(
        eq([
          # .#....###24...#..
          # ##...##.13#67..9#
          # ##...#...5.8####.
          # ..#.....X...###..
          # ..#.#.....#....##
          {8, 1},
          {9, 0},
          {9, 1},
          {10, 0},
          {9, 2},
          {11, 1},
          {12, 1},
          {11, 2},
          {15, 1},

          # .#....###.....#..
          # ##...##...#.....#
          # ##...#......1234.
          # ..#.....X...5##..
          # ..#.9.....8....76
          {12, 2},
          {13, 2},
          {14, 2},
          {15, 2},
          {12, 3},
          {16, 4},
          {15, 4},
          {10, 4},
          {4, 4},

          # .8....###.....#..
          # 56...9#...#.....#
          # 34...7...........
          # ..2.....X....##..
          # ..1..............
          {2, 4},
          {2, 3},
          {0, 2},
          {1, 2},
          {0, 1},
          {1, 1},
          {5, 2},
          {1, 0},
          {5, 1},

          # ......234.....6..
          # ......1...5.....7
          # .................
          # ........X....89..
          # .................
          {6, 1},
          {6, 0},
          {7, 0},
          {8, 0},
          {10, 1},
          {14, 0},
          {16, 1},
          {13, 3},
          {14, 3}
        ])
      )
    end

    it "tests a bigger example" do
      zapped_order =
        AoC.Day10.zap_asteroids(
          [
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
          ],
          {11, 13}
        )

      expect(Enum.slice(zapped_order, 0..2)) |> to(eq([{11, 12}, {12, 1}, {12, 2}]))
      expect(Enum.at(zapped_order, 9)) |> to(eq({12, 8}))
      expect(Enum.at(zapped_order, 19)) |> to(eq({16, 0}))
      expect(Enum.at(zapped_order, 49)) |> to(eq({16, 9}))
      expect(Enum.at(zapped_order, 99)) |> to(eq({10, 16}))
      expect(Enum.at(zapped_order, 198)) |> to(eq({9, 6}))
      expect(Enum.at(zapped_order, 199)) |> to(eq({8, 2}))
      expect(Enum.at(zapped_order, 200)) |> to(eq({10, 9}))
      expect(Enum.at(zapped_order, 298)) |> to(eq({11, 1}))
    end
  end

  example_group "angle/2" do
    it("positive Y axis",
      do: expect(AoC.Day10.angle({0, 0}, {0, -1})) |> to(eq(Math.pi() * 0 / 4))
    )

    it("quadrant I", do: expect(AoC.Day10.angle({0, 0}, {1, -1})) |> to(eq(Math.pi() * 1 / 4)))

    it("positive X axis", do: expect(AoC.Day10.angle({0, 0}, {1, 0})) |> to(eq(Math.pi() * 2 / 4)))

    it("quadrant IV", do: expect(AoC.Day10.angle({0, 0}, {1, 1})) |> to(eq(Math.pi() * 3 / 4)))

    it("negative Y axis", do: expect(AoC.Day10.angle({0, 0}, {0, 1})) |> to(eq(Math.pi() * 4 / 4)))

    it("quadrant III", do: expect(AoC.Day10.angle({0, 0}, {-1, 1})) |> to(eq(Math.pi() * 5 / 4)))

    it("negative X axis",
      do: expect(AoC.Day10.angle({0, 0}, {-1, 0})) |> to(eq(Math.pi() * 6 / 4))
    )

    it("quadrant II", do: expect(AoC.Day10.angle({0, 0}, {-1, -1})) |> to(eq(Math.pi() * 7 / 4)))
  end

  example_group "detected_count" do
    it do
      # .7..7
      # .....
      # 67775
      # ....7
      # ...87

      all_positions = [
        {1, 0},
        {4, 0},
        {0, 2},
        {1, 2},
        {2, 2},
        {3, 2},
        {4, 2},
        {4, 3},
        {3, 4},
        {4, 4}
      ]

      expect(AoC.Day10.detected_count({1, 0}, List.delete(all_positions, {1, 0}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({4, 0}, List.delete(all_positions, {4, 0}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({0, 2}, List.delete(all_positions, {0, 2}))) |> to(eq(6))
      expect(AoC.Day10.detected_count({1, 2}, List.delete(all_positions, {1, 2}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({2, 2}, List.delete(all_positions, {2, 2}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({3, 2}, List.delete(all_positions, {3, 2}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({4, 2}, List.delete(all_positions, {4, 2}))) |> to(eq(5))
      expect(AoC.Day10.detected_count({4, 3}, List.delete(all_positions, {4, 3}))) |> to(eq(7))
      expect(AoC.Day10.detected_count({3, 4}, List.delete(all_positions, {3, 4}))) |> to(eq(8))
      expect(AoC.Day10.detected_count({4, 4}, List.delete(all_positions, {4, 4}))) |> to(eq(7))
    end
  end

  example_group "distance/2" do
    it(do: expect(AoC.Day10.distance({0, 0}, {1, 0})) |> to(eq(1)))
    it(do: expect(AoC.Day10.distance({0, 0}, {0, 1})) |> to(eq(1)))
    it(do: expect(AoC.Day10.distance({0, 0}, {-1, 0})) |> to(eq(1)))
    it(do: expect(AoC.Day10.distance({0, 0}, {1, 1})) |> to(eq(Math.sqrt(2))))
    it(do: expect(AoC.Day10.distance({1, 2}, {4, 6})) |> to(eq(5)))
  end

  example_group "filter/2" do
    it do
      map_data = [".#..#", ".....", "#####", "....#", "...##"]
      m = AoC.Day10.map_data_to_matrix(map_data)

      expect(AoC.Day10.filter(m, fn {_, value} -> value == 1 end))
      |> to(eq([{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}, {4, 4}]))
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
    it(
      do:
        expect(AoC.Day10.max_detected([".#..#", ".....", "#####", "....#", "...##"]))
        |> to(eq({{3, 4}, 8}))
    )

    it(
      do:
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
        |> to(eq({{5, 8}, 33}))
    )

    it(
      do:
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
        |> to(eq({{1, 2}, 35}))
    )

    it(
      do:
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
        |> to(eq({{6, 3}, 41}))
    )

    it(
      do:
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
        |> to(eq({{11, 13}, 210}))
    )
  end

  example_group "position_angles/2" do
    # .7..7
    # .....
    # 67775
    # ....7
    # ...87

    it do
      this_position = {4, 2}
      other_positions = [{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 3}, {3, 4}, {4, 4}]

      expect(AoC.Day10.position_angles(this_position, other_positions))
      |> to(
        eq([
          {{1, 0}, 5.3003915839322575},
          {{4, 0}, 0},
          {{0, 2}, Math.pi() * 3 / 2},
          {{1, 2}, Math.pi() * 3 / 2},
          {{2, 2}, Math.pi() * 3 / 2},
          {{3, 2}, Math.pi() * 3 / 2},
          {{4, 3}, Math.pi()},
          {{3, 4}, 3.6052402625905993},
          {{4, 4}, Math.pi()}
        ])
      )
    end
  end

  example_group "zap/2" do
    it(
      do:
        expect(AoC.Day10.zap([{0, [{{1, 8}, 0}, {{0, 8}, 0}]}, {1, [{{2, 8}, 1}]}], []))
        |> to(eq([{1, 8}, {2, 8}, {0, 8}]))
    )
  end
end

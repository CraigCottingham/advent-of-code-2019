defmodule AoC.Day03.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests closest_intersection/2" do
      p = AoC.Day03.closest_intersection([["R8", "U5", "L5", "D3"], ["U7", "R6", "D4", "L4"]])
      expect(p) |> to(eq({3, 3}))
      expect(AoC.Day03.manhattan_distance({0, 0}, p)) |> to(eq(6))

      p =
        AoC.Day03.closest_intersection([
          ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"],
          ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"]
        ])

      expect(p) |> to(eq({155, 4}))
      expect(AoC.Day03.manhattan_distance({0, 0}, p)) |> to(eq(159))

      p =
        AoC.Day03.closest_intersection([
          ["R98", "U47", "R26", "D63", "R33", "U87", "L62", "D20", "R33", "U53", "R51"],
          ["U98", "R91", "D20", "R16", "D67", "R40", "U7", "R15", "U6", "R7"]
        ])

      expect(p) |> to(eq({124, 11}))
      expect(AoC.Day03.manhattan_distance({0, 0}, p)) |> to(eq(135))
    end

    it "tests intersect?/2" do
      expect(AoC.Day03.intersect?({{0, 0}, {2, 0}}, {{1, 1}, {1, -1}})) |> to(be_truthy())
      expect(AoC.Day03.intersect?({{0, 0}, {2, 0}}, {{1, 1}, {1, 3}})) |> to(be_falsy())
      expect(AoC.Day03.intersect?({{0, 0}, {2, 0}}, {{-1, 1}, {-1, 1}})) |> to(be_falsy())
    end

    it "tests intersection/2" do
      expect(AoC.Day03.intersection({{3, 5}, {3, 2}}, {{6, 3}, {2, 3}})) |> to(eq({3, 3}))
      expect(AoC.Day03.intersection({{8, 5}, {3, 5}}, {{6, 7}, {6, 3}})) |> to(eq({6, 5}))
      expect(AoC.Day03.intersection({{0, 0}, {8, 0}}, {{0, 0}, {0, 7}})) |> to(eq({0, 0}))
    end

    it "tests length_to_point/3" do
      expect(
        AoC.Day03.length_to_point(
          [{{0, 0}, {8, 0}}, {{8, 0}, {8, 5}}, {{8, 5}, {3, 5}}, {{3, 5}, {3, 2}}],
          {6, 5}
        )
      )
      |> to(eq(15))

      expect(
        AoC.Day03.length_to_point(
          [{{0, 0}, {8, 0}}, {{8, 0}, {8, 5}}, {{8, 5}, {3, 5}}, {{3, 5}, {3, 2}}],
          {3, 3}
        )
      )
      |> to(eq(20))
    end

    it "tests manhattan_distance/2" do
      expect(AoC.Day03.manhattan_distance({0, 0}, {3, 3})) |> to(eq(6))
      expect(AoC.Day03.manhattan_distance({6, 5}, {0, 0})) |> to(eq(11))
    end

    it "tests orientation/3" do
      expect(AoC.Day03.orientation({0, 0}, {1, 1}, {1, 0})) |> to(eq(:cw))
      expect(AoC.Day03.orientation({0, 0}, {1, 1}, {0, 1})) |> to(eq(:ccw))
      expect(AoC.Day03.orientation({0, 0}, {1, 1}, {2, 2})) |> to(eq(:colinear))
    end

    it "tests path_to_segments/3" do
      expect(AoC.Day03.path_to_segments(["R8", "U5", "L5", "D3"]))
      |> to(eq([{{0, 0}, {8, 0}}, {{8, 0}, {8, 5}}, {{8, 5}, {3, 5}}, {{3, 5}, {3, 2}}]))

      expect(
        AoC.Day03.path_to_segments(["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"])
      )
      |> to(
        eq([
          {{0, 0}, {75, 0}},
          {{75, 0}, {75, -30}},
          {{75, -30}, {158, -30}},
          {{158, -30}, {158, 53}},
          {{158, 53}, {146, 53}},
          {{146, 53}, {146, 4}},
          {{146, 4}, {217, 4}},
          {{217, 4}, {217, 11}},
          {{217, 11}, {145, 11}}
        ])
      )

      expect(AoC.Day03.path_to_segments(["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"]))
      |> to(
        eq([
          {{0, 0}, {0, 62}},
          {{0, 62}, {66, 62}},
          {{66, 62}, {66, 117}},
          {{66, 117}, {100, 117}},
          {{100, 117}, {100, 46}},
          {{100, 46}, {155, 46}},
          {{155, 46}, {155, -12}},
          {{155, -12}, {238, -12}}
        ])
      )
    end

    it "tests shortest_path/2" do
      expect(AoC.Day03.shortest_path([["R8", "U5", "L5", "D3"], ["U7", "R6", "D4", "L4"]]))
      |> to(eq(30))

      expect(
        AoC.Day03.shortest_path([
          ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"],
          ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"]
        ])
      )
      |> to(eq(610))

      expect(
        AoC.Day03.shortest_path([
          ["R98", "U47", "R26", "D63", "R33", "U87", "L62", "D20", "R33", "U53", "R51"],
          ["U98", "R91", "D20", "R16", "D67", "R40", "U7", "R15", "U6", "R7"]
        ])
      )
      |> to(eq(410))
    end
  end
end

defmodule AoC.Day17.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
  end

  example_group "alignment_parameter/1" do
    it(do: expect(AoC.Day17.alignment_parameter({2, 2})) |> to(eq(4)))
    it(do: expect(AoC.Day17.alignment_parameter({4, 2})) |> to(eq(8)))
    it(do: expect(AoC.Day17.alignment_parameter({4, 6})) |> to(eq(24)))
    it(do: expect(AoC.Day17.alignment_parameter({4, 10})) |> to(eq(40)))
  end

  example_group "extract_horizontal_segments/1" do
    it do
      view = [
        "..#..........",
        "..#..........",
        "#######...###",
        "#.#...#...#.#",
        "#############",
        "..#...#...#..",
        "..#####...^.."
      ]

      expect(AoC.Day17.extract_horizontal_segments(view))
      |> to(eq([{{2, 10}, {2, 12}}, {{2, 0}, {2, 6}}, {{4, 0}, {4, 12}}, {{6, 2}, {6, 6}}]))
    end
  end

  example_group "extract_vertical_segments/1" do
    it do
      view = [
        "..#..........",
        "..#..........",
        "#######...###",
        "#.#...#...#.#",
        "#############",
        "..#...#...#..",
        "..#####...^.."
      ]

      expect(AoC.Day17.extract_vertical_segments(view))
      |> to(
        eq([
          {{2, 0}, {4, 0}},
          {{0, 2}, {6, 2}},
          {{2, 6}, {6, 6}},
          {{2, 10}, {6, 10}},
          {{2, 12}, {4, 12}}
        ])
      )
    end
  end

  example_group "flip_diagonal/1" do
    it do
      view = [
        "..#..........",
        "..#..........",
        "#######...###",
        "#.#...#...#.#",
        "#############",
        "..#...#...#..",
        "..#####...^.."
      ]

      flipped = [
        "..###..",
        "..#.#..",
        "#######",
        "..#.#.#",
        "..#.#.#",
        "..#.#.#",
        "..#####",
        "....#..",
        "....#..",
        "....#..",
        "..####^",
        "..#.#..",
        "..###.."
      ]

      expect(AoC.Day17.flip_diagonal(view)) |> to(eq(flipped))
    end
  end

  example_group "intersections/1" do
    it do
      view = [
        "..#..........",
        "..#..........",
        "#######...###",
        "#.#...#...#.#",
        "#############",
        "..#...#...#..",
        "..#####...^.."
      ]

      expect(AoC.Day17.intersections(view)) |> to(eq([{2, 2}, {4, 2}, {4, 6}, {4, 10}]))
    end
  end
end

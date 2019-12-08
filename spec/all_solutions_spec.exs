defmodule AllSolutions.Spec do
  @moduledoc false

  use ESpec

  example_group "day 01" do
    it("part 1",
      do:
        expect(AoC.Day01.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_01") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day01.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_01") |> List.last()))
    )
  end

  example_group "day 02" do
    it("part 1",
      do:
        expect(AoC.Day02.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_02") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day02.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_02") |> List.last()))
    )
  end

  example_group "day 03" do
    it("part 1",
      do:
        expect(AoC.Day03.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_03") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day03.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_03") |> List.last()))
    )
  end

  example_group "day 04" do
    it("part 1",
      do:
        expect(AoC.Day04.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_04") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day04.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_04") |> List.last()))
    )
  end

  example_group "day 05" do
    it("part 1",
      do:
        expect(AoC.Day05.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_05") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day05.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_05") |> List.last()))
    )
  end

  example_group "day 06" do
    it("part 1",
      do:
        expect(AoC.Day06.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_06") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day06.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_06") |> List.last()))
    )
  end

  example_group "day 07" do
    it("part 1",
      do:
        expect(AoC.Day07.part_1())
        |> to(eq(shared.solutions |> Map.fetch!("day_07") |> List.first()))
    )

    it("part 2",
      do:
        expect(AoC.Day07.part_2())
        |> to(eq(shared.solutions |> Map.fetch!("day_07") |> List.last()))
    )
  end

  example_group "day 07" do
  end
end

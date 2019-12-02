defmodule AllSolutions.Spec do
  @moduledoc false

  use ESpec

  example_group "day 01" do
    it "part 1", do: expect(AoC.Day01.part_1()) |> to(eq(shared.solutions |> Map.fetch!("day_01") |> List.first()))
    it "part 2", do: expect(AoC.Day01.part_2()) |> to(eq(shared.solutions |> Map.fetch!("day_01") |> List.last))
  end

  example_group "day 02" do
    it "part 1", do: expect(AoC.Day02.part_1()) |> to(eq(shared.solutions |> Map.fetch!("day_02") |> List.first()))
  #   it "part 2", do: expect(AoC.Day02.part_2()) |> to(eq(shared.solutions |> Map.fetch!("day_02") |> List.last))
  end
end

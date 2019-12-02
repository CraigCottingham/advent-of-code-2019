defmodule AoC.Day01.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests calculate_fuel/1" do
      expect(AoC.Day01.calculate_fuel(12)) |> to(eq(2))
      expect(AoC.Day01.calculate_fuel(14)) |> to(eq(2))
      expect(AoC.Day01.calculate_fuel(1969)) |> to(eq(654))
      expect(AoC.Day01.calculate_fuel(100756)) |> to(eq(33583))
    end
  end
end

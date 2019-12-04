defmodule AoC.Day04.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests has_consecutive_digits?/1" do
      expect(AoC.Day04.has_consecutive_digits?(111_111)) |> to(be_truthy())
      expect(AoC.Day04.has_consecutive_digits?(223_450)) |> to(be_truthy())
      expect(AoC.Day04.has_consecutive_digits?(123_789)) |> to(be_falsy())
    end

    it "tests has_small_consecutive_block?/1" do
      expect(AoC.Day04.has_small_consecutive_block?(112_233)) |> to(be_truthy())
      expect(AoC.Day04.has_small_consecutive_block?(123_444)) |> to(be_falsy())
      expect(AoC.Day04.has_small_consecutive_block?(111_122)) |> to(be_truthy())
    end

    it "tests is_monotonically_increasing?/1" do
      expect(AoC.Day04.is_monotonically_increasing?(111_111)) |> to(be_truthy())
      expect(AoC.Day04.is_monotonically_increasing?(223_450)) |> to(be_falsy())
      expect(AoC.Day04.is_monotonically_increasing?(123_789)) |> to(be_truthy())
    end
  end
end

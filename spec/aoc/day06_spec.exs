defmodule AoC.Day06.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    example_group "add_orbit/3" do
      it "tests adding to an empty data structure" do
        expect(AoC.Day06.add_orbit(%{}, "A", "B")) |> to(eq(%{"A" => ["B"], "B" => []}))
      end

      it "tests adding a new parent" do
        expect(AoC.Day06.add_orbit(%{"A" => ["B"], "B" => []}, "C", "D"))
        |> to(eq(%{"A" => ["B"], "B" => [], "C" => ["D"], "D" => []}))
      end

      it "tests adding a new child" do
        expect(AoC.Day06.add_orbit(%{"A" => ["B"], "B" => []}, "A", "C"))
        |> to(eq(%{"A" => ["C", "B"], "B" => [], "C" => []}))
      end

      it "tests adding a new orbit between existing bodies" do
        expect(AoC.Day06.add_orbit(%{"A" => ["B"], "B" => [], "C" => ["D"], "D" => []}, "B", "C"))
        |> to(eq(%{"A" => ["B"], "B" => ["C"], "C" => ["D"], "D" => []}))
      end

      it "tests a whole system" do
        build_system()
        |> expect()
        |> to(
          eq(%{
            "COM" => ["B"],
            "B" => ["G", "C"],
            "C" => ["D"],
            "D" => ["I", "E"],
            "E" => ["J", "F"],
            "F" => [],
            "G" => ["H"],
            "H" => [],
            "I" => [],
            "J" => ["K"],
            "K" => ["L"],
            "L" => []
          })
        )
      end
    end

    example_group "tree_depth/2" do
      it("tests depth of COM",
        do: expect(AoC.Day06.tree_depth(build_system(), "COM")) |> to(eq(0))
      )

      it("tests depth of B", do: expect(AoC.Day06.tree_depth(build_system(), "B")) |> to(eq(1)))
      it("tests depth of C", do: expect(AoC.Day06.tree_depth(build_system(), "C")) |> to(eq(2)))
      it("tests depth of D", do: expect(AoC.Day06.tree_depth(build_system(), "D")) |> to(eq(3)))
      it("tests depth of E", do: expect(AoC.Day06.tree_depth(build_system(), "E")) |> to(eq(4)))
      it("tests depth of F", do: expect(AoC.Day06.tree_depth(build_system(), "F")) |> to(eq(5)))
      it("tests depth of G", do: expect(AoC.Day06.tree_depth(build_system(), "G")) |> to(eq(2)))
      it("tests depth of H", do: expect(AoC.Day06.tree_depth(build_system(), "H")) |> to(eq(3)))
      it("tests depth of I", do: expect(AoC.Day06.tree_depth(build_system(), "I")) |> to(eq(4)))
      it("tests depth of J", do: expect(AoC.Day06.tree_depth(build_system(), "J")) |> to(eq(5)))
      it("tests depth of K", do: expect(AoC.Day06.tree_depth(build_system(), "K")) |> to(eq(6)))
      it("tests depth of L", do: expect(AoC.Day06.tree_depth(build_system(), "L")) |> to(eq(7)))
    end

    example_group "total_orbits/1" do
      it do
        expect(AoC.Day06.total_orbits(build_system())) |> to(eq(42))
      end
    end
  end

  defp build_system do
    %{}
    |> AoC.Day06.add_orbit("COM", "B")
    |> AoC.Day06.add_orbit("B", "C")
    |> AoC.Day06.add_orbit("C", "D")
    |> AoC.Day06.add_orbit("D", "E")
    |> AoC.Day06.add_orbit("E", "F")
    |> AoC.Day06.add_orbit("B", "G")
    |> AoC.Day06.add_orbit("G", "H")
    |> AoC.Day06.add_orbit("D", "I")
    |> AoC.Day06.add_orbit("E", "J")
    |> AoC.Day06.add_orbit("J", "K")
    |> AoC.Day06.add_orbit("K", "L")
  end
end

defmodule AoC.Day06.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    example_group "root/1" do
      it do
        expect(AoC.Day06.root(build_system())) |> to(eq("COM"))
      end
    end

    example_group "total_orbits/1" do
      it do
        expect(AoC.Day06.total_orbits(build_system())) |> to(eq(42))
      end
    end
  end

  defp build_system do
    data = [
      {"COM", "B"},
      {"B", "C"},
      {"C", "D"},
      {"D", "E"},
      {"E", "F"},
      {"B", "G"},
      {"G", "H"},
      {"D", "I"},
      {"E", "J"},
      {"J", "K"},
      {"K", "L"}
    ]

    Enum.reduce(data, Graph.new(), fn {parent, child}, graph ->
      graph
      |> Graph.add_vertices([parent, child])
      |> Graph.add_edge(child, parent)
    end)
  end
end

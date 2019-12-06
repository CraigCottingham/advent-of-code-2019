defmodule AoC.Day06.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    example_group "orbital_transfers/3" do
      it do
        graph =
          build_graph(:undirected)
          |> Graph.add_vertices(["K", "YOU"])
          |> add_edges("K", "YOU", :undirected)
          |> Graph.add_vertices(["I", "SAN"])
          |> add_edges("I", "SAN", :undirected)

        expect(AoC.Day06.orbital_transfers(graph, "YOU", "SAN")) |> to(eq(4))
      end
    end

    example_group "root/1" do
      it do
        expect(AoC.Day06.root(build_graph())) |> to(eq("COM"))
      end
    end

    example_group "total_orbits/1" do
      it do
        expect(AoC.Day06.total_orbits(build_graph())) |> to(eq(42))
      end
    end
  end

  defp build_graph(type \\ :directed) do
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
      |> add_edges(parent, child, type)
    end)
  end

  defp add_edges(graph, parent, child, :directed) do
    Graph.add_edge(graph, child, parent)
  end

  defp add_edges(graph, parent, child, :undirected) do
    graph
    |> Graph.add_edge(child, parent)
    |> Graph.add_edge(parent, child)
  end
end

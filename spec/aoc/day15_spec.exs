defmodule AoC.Day15.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it do
      graph =
        Graph.new()
        |> Graph.add_edge({0, 0}, {1, 0})
        |> Graph.add_edge({0, 0}, {0, 1})
        |> Graph.add_edge({0, 1}, {-1, 1})

      expect(Graph.get_shortest_path(graph, {0, 0}, {-1, 1})) |> to(eq([{0, 0}, {0, 1}, {-1, 1}]))
    end
  end
end

defmodule AoC.Day06 do
  @moduledoc false

  def part_1 do
    "data/day06-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> load_graph()
    |> total_orbits()
  end

  def part_2 do
  end

  def root(graph),
    do: Enum.find(Graph.vertices(graph), fn v -> Graph.out_edges(graph, v) == [] end)

  def total_orbits(graph) do
    root = root(graph)

    Enum.reduce(Graph.vertices(graph), 0, fn
      ^root, acc ->
        acc

      v, acc ->
        graph
        |> Graph.get_shortest_path(v, root)
        |> Enum.count()
        |> Kernel.+(acc)
        |> Kernel.-(1)
    end)
  end

  defp add_orbit(graph, parent, child) do
    graph
    |> Graph.add_vertices([parent, child])
    |> Graph.add_edge(child, parent)
  end

  defp load_graph(lines) do
    Enum.reduce(lines, Graph.new(), fn line, graph ->
      {parent, child} = split_orbit_string(line)
      add_orbit(graph, parent, child)
    end)
  end

  defp split_orbit_string(str), do: str |> String.split(")") |> List.to_tuple()
end

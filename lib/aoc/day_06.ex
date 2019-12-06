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
    "data/day06-input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> load_graph(:undirected)
    |> orbital_transfers("YOU", "SAN")
  end

  def orbital_transfers(graph, from, to) do
    shortest_path = Graph.get_shortest_path(graph, from, to)

    # -1 because we don't need to transfer from YOU to whatever YOU is orbiting
    # -1 because we don't need to transfer from whatever SAN is orbiting to SAN
    # -1 because shortest_path is the vertices, and we want the edges between them
    Enum.count(shortest_path) - 3
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

  defp add_orbit(graph, parent, child, :directed) do
    graph
    |> Graph.add_vertices([parent, child])
    |> Graph.add_edge(child, parent)
  end

  defp add_orbit(graph, parent, child, :undirected) do
    graph
    |> Graph.add_vertices([parent, child])
    |> Graph.add_edge(child, parent)
    |> Graph.add_edge(parent, child)
  end

  defp load_graph(lines, type \\ :directed) do
    Enum.reduce(lines, Graph.new(), fn line, graph ->
      {parent, child} = split_orbit_string(line)
      add_orbit(graph, parent, child, type)
    end)
  end

  defp split_orbit_string(str), do: str |> String.split(")") |> List.to_tuple()
end

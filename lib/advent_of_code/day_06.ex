defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> clean_input()
    |> make_graph()
    |> total_orbits()
  end

  def part2(input) do
    orbits = clean_input(input)
    graph = make_graph(orbits)
    find_distance(graph, orbits, "SAN", "YOU")
  end

  def clean_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      [a, b] = String.split(x, ")")
      {b, a}
    end)
    |> Map.new()
  end

  def make_graph(orbits) do
    vertices =
      for({k, v} <- orbits, do: [k, v])
      |> List.flatten()
      |> Enum.into(MapSet.new())

    graph = :digraph.new()

    Enum.each(vertices, fn vert ->
      :digraph.add_vertex(graph, vert)
    end)

    Enum.each(orbits, fn {from, to} ->
      :digraph.add_edge(graph, from, to)
    end)

    graph
  end

  def make_undirected(graph, orbits) do
    Enum.each(orbits, fn {from, to} ->
      :digraph.add_edge(graph, to, from)
    end)

    graph
  end

  def total_orbits(graph) do
    graph
    |> :digraph.vertices()
    |> Enum.map(&calc_orbits(graph, &1, 0))
    |> Enum.sum()
  end

  def calc_orbits(graph, orbit, acc) do
    graph
    |> :digraph.out_neighbours(orbit)
    |> Enum.map(&calc_orbits(graph, &1, 1))
    |> Enum.sum()
    |> Kernel.+(acc)
  end

  def find_distance(graph, orbits, orbit1, orbit2) do
    obj1 = graph |> :digraph.out_neighbours(orbit1) |> List.first()
    obj2 = graph |> :digraph.out_neighbours(orbit2) |> List.first()
    make_undirected(graph, orbits)

    graph
    |> :digraph.get_short_path(obj1, obj2)
    |> Enum.count()
    |> Kernel.-(1)
  end
end

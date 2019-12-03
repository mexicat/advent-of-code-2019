defmodule AdventOfCode.Day03 do
  def part1(wires) do
    wires
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&parse_wire/1)
    |> find_common_points()
    |> select_closest_point()
  end

  def part2(wires) do
    wires =
      wires
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&parse_wire/1)

    points = wires |> find_common_points()

    for point <- points do
      Enum.reduce(wires, 0, fn {_, positions}, acc ->
        acc + steps_to_point(positions, point)
      end)
    end
    |> Enum.sort()
    |> List.first()
  end

  def parse_wire(moves) do
    Enum.reduce(
      moves,
      {{0, 0}, []},
      fn move, {{x, y}, positions} ->
        {dir, amt} = String.split_at(move, 1)
        amt = String.to_integer(amt)

        case dir do
          "U" ->
            {{x, y + amt}, for(d <- y..(y + amt - 1), do: {x, d}, into: positions)}

          "D" ->
            {{x, y - amt}, for(d <- y..(y - amt + 1), do: {x, d}, into: positions)}

          "R" ->
            {{x + amt, y}, for(d <- x..(x + amt - 1), do: {d, y}, into: positions)}

          "L" ->
            {{x - amt, y}, for(d <- x..(x - amt + 1), do: {d, y}, into: positions)}
        end
      end
    )
  end

  def find_common_points(wires) do
    wires
    |> Enum.reduce(nil, fn
      {_, positions}, nil -> MapSet.new(positions)
      {_, positions}, acc -> MapSet.intersection(acc, MapSet.new(positions))
    end)
    |> MapSet.delete({0, 0})
  end

  def steps_to_point(positions, point) do
    positions
    |> Enum.find_index(fn x -> x == point end)
  end

  def select_closest_point(positions) do
    positions
    |> MapSet.to_list()
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.sort()
    |> List.first()
  end
end

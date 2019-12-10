defmodule AdventOfCode.Day10 do
  def part1(input) do
    points =
      input
      |> extract_points()

    points
    |> Enum.map(&amount_of_reachable_points(&1, points))
    |> Enum.max_by(fn {_, count} -> count end)
  end

  def part2(input) do
    {{x1, y1}, _} = part1(input)

    {first, last} =
      input
      |> extract_points()
      |> List.delete({x1, y1})
      |> Enum.map(fn {x2, y2} ->
        {{x2, y2}, calc_angle({x1, y1}, {x2, y2})}
      end)
      |> Enum.sort_by(&distance_to(elem(&1, 0), {x1, y1}), &>=/2)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.split_with(fn {_, angle} -> angle >= :math.atan2(-1, 0) end)

    asteroids = first ++ last

    asteroids
    |> Enum.map(fn {_, angle} -> angle end)
    |> Enum.uniq()
    |> Stream.cycle()
    |> Enum.reduce_while({asteroids, []}, fn angle, {to_parse, acc} ->
      maybe_next = Enum.find(to_parse, fn {_, a} -> angle == a end)

      cond do
        to_parse == [] -> {:halt, Enum.reverse(acc)}
        maybe_next == nil -> {:cont, {to_parse, acc}}
        true -> {:cont, {List.delete(to_parse, maybe_next), [maybe_next | acc]}}
      end
    end)
  end

  def extract_points(input) do
    for {row, row_index} <- input |> String.split("\n") |> Enum.with_index(),
        {col, col_index} <- row |> String.codepoints() |> Enum.with_index(),
        col == "#",
        do: {col_index, row_index}
  end

  def amount_of_reachable_points({x1, y1}, points) do
    count =
      points
      |> List.delete({x1, y1})
      |> Enum.map(fn {x2, y2} -> calc_angle({x1, y1}, {x2, y2}) end)
      |> Enum.uniq()
      |> Enum.count()

    {{x1, y1}, count}
  end

  def calc_angle({x1, y1}, {x2, y2}) do
    :math.atan2(y2 - y1, x2 - x1)
  end

  def distance_to({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 + y2)
  end
end

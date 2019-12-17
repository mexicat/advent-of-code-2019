defmodule AdventOfCode.Day17 do
  def part1(program) do
    {:stop, intcode} =
      program
      |> IntCodeFun.new(nil)
      |> IntCodeFun.run()

    intcode |> Map.get(:output) |> Enum.reverse() |> parse_intersections()
  end

  def parse_intersections(grid) do
    grid =
      grid
      |> Enum.with_index()

    {_, index} = grid |> List.keyfind(10, 0)
    length = index + 1

    grid
    |> Enum.reduce([], fn
      {?#, p}, acc ->
        if Enum.member?(grid, {?#, p - length}) and
             Enum.member?(grid, {?#, p + length}) and
             Enum.member?(grid, {?#, p - 1}) and
             Enum.member?(grid, {?#, p + 1}) do
          [p | acc]
        else
          acc
        end

      _, acc ->
        acc
    end)
    |> Enum.map(fn point ->
      x = div(point, length)
      y = rem(point, length)
      x * y
    end)
    |> Enum.sum()
  end

  def part2(program) do
    {:stop, intcode} =
      program
      |> IntCodeFun.new(nil)
      |> IntCodeFun.set_input(
        'A,B,A,C,B,A,C,B,A,C\nL,6,L,4,R,12\nL,6,R,12,R,12,L,8\nL,6,L,10,L,10,L,6\nn\n'
      )
      |> IntCodeFun.run()

    intcode.output |> hd()
  end
end

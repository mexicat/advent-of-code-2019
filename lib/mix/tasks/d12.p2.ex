defmodule Mix.Tasks.D12.P2 do
  use Mix.Task

  import AdventOfCode.Day12

  @shortdoc "Day 12 Part 2"
  def run(args) do
    input = "<x=17, y=-12, z=13>\n<x=2, y=1, z=1>\n<x=-1, y=-17, z=7>\n<x=12, y=-14, z=18>"

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end

defmodule AdventOfCode.Day19 do
  def part1(program) do
    intcode = IntCodeFun.new(program, nil)

    for y <- 0..49, x <- 0..49, into: Map.new() do
      {:stop, result} = intcode |> IntCodeFun.set_input([x, y]) |> IntCodeFun.run()
      {{x, y}, hd(result.output)}
    end
    |> Enum.filter(&(elem(&1, 1) == 1))
    |> Enum.count()
  end

  def part2(program) do
    intcode = IntCodeFun.new(program, nil)

    Enum.reduce_while(Stream.cycle([:ok]), {0, 300}, fn _, {acc_x, acc_y} ->
      {corner_x, corner_y} =
        Enum.reduce_while(acc_x..acc_y, nil, fn x, _ ->
          {:stop, result} = intcode |> IntCodeFun.set_input([x, acc_y]) |> IntCodeFun.run()

          case hd(result.output) do
            1 -> {:halt, {x, acc_y}}
            0 -> {:cont, nil}
          end
        end)

      {:stop, result} =
        intcode |> IntCodeFun.set_input([corner_x + 99, corner_y - 99]) |> IntCodeFun.run()

      case hd(result.output) do
        1 -> {:halt, {corner_x, corner_y - 99}}
        0 -> {:cont, {corner_x, acc_y + 1}}
      end
    end)
  end
end

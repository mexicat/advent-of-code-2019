defmodule AdventOfCode.Day02 do
  def part1(opcodes) do
    parse_opcodes(opcodes, 0, nil)
  end

  def part2(opcodes, to_find) do
    for noun <- 0..99, verb <- 0..99 do
      opcodes =
        opcodes
        |> List.replace_at(1, noun)
        |> List.replace_at(2, verb)

      Task.async(fn -> {opcodes |> parse_opcodes(0, nil) |> Enum.at(0), noun, verb} end)
    end
    |> Enum.map(&Task.await/1)
    |> Enum.find(nil, fn {x, _, _} -> x == to_find end)
  end

  def parse_opcodes(opcodes, at, nil) do
    instructions = Enum.drop(opcodes, at)
    parse_opcodes(opcodes, at, instructions)
  end

  def parse_opcodes(opcodes, at, [1, pos_a, pos_b, target | _]) do
    {a, b} = {Enum.at(opcodes, pos_a), Enum.at(opcodes, pos_b)}

    opcodes
    |> List.replace_at(target, a + b)
    |> parse_opcodes(at + 4, nil)
  end

  def parse_opcodes(opcodes, at, [2, pos_a, pos_b, target | _]) do
    {a, b} = {Enum.at(opcodes, pos_a), Enum.at(opcodes, pos_b)}

    opcodes
    |> List.replace_at(target, a * b)
    |> parse_opcodes(at + 4, nil)
  end

  def parse_opcodes(opcodes, _at, [99 | _]) do
    opcodes
  end
end

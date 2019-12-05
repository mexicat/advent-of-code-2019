defmodule AdventOfCode.Day05 do
  def part1(opcodes, input) do
    parse_opcodes(opcodes, input, 0, nil)
  end

  def part2(opcodes, input) do
    parse_opcodes(opcodes, input, 0, nil)
  end

  def parse_opcodes(opcodes, input, at, nil) do
    instructions = Enum.drop(opcodes, at)
    parse_opcodes(opcodes, input, at, instructions)
  end

  def parse_opcodes(opcodes, input, at, [op | rest]) do
    {modes, operation} = op |> Integer.to_string() |> String.split_at(-2)
    modes = modes |> String.reverse() |> String.graphemes()
    # IO.puts("Operation #{operation} at #{at}")
    operation(opcodes, input, String.to_integer(operation), modes, at, rest)
  end

  # add
  def operation(opcodes, input, 1, modes, at, [a, b, target | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    target = if Enum.at(modes, 2) == "1", do: at + 3, else: target

    opcodes
    |> List.replace_at(target, a + b)
    |> parse_opcodes(input, at + 4, nil)
  end

  # multiply
  def operation(opcodes, input, 2, modes, at, [a, b, target | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    target = if Enum.at(modes, 2) == "1", do: at + 3, else: target

    opcodes
    |> List.replace_at(target, a * b)
    |> parse_opcodes(input, at + 4, nil)
  end

  # save
  def operation(opcodes, input, 3, _modes, at, [a | _]) do
    opcodes
    |> List.replace_at(a, input)
    |> parse_opcodes(input, at + 2, nil)
  end

  # output
  def operation(opcodes, input, 4, _modes, at, [a | _]) do
    IO.puts(Enum.at(opcodes, a))

    opcodes
    |> parse_opcodes(input, at + 2, nil)
  end

  # jump if true
  def operation(opcodes, input, 5, modes, at, [a, b | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    at = if a != 0, do: b, else: at + 3

    parse_opcodes(opcodes, input, at, nil)
  end

  # jump if false
  def operation(opcodes, input, 6, modes, at, [a, b | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    at = if a == 0, do: b, else: at + 3

    parse_opcodes(opcodes, input, at, nil)
  end

  # less than
  def operation(opcodes, input, 7, modes, at, [a, b, target | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    target = if Enum.at(modes, 2) == "1", do: at + 3, else: target

    opcodes
    |> List.replace_at(target, if(a < b, do: 1, else: 0))
    |> parse_opcodes(input, at + 4, nil)
  end

  # equals
  def operation(opcodes, input, 8, modes, at, [a, b, target | _]) do
    a = if Enum.at(modes, 0) == "1", do: a, else: Enum.at(opcodes, a)
    b = if Enum.at(modes, 1) == "1", do: b, else: Enum.at(opcodes, b)
    target = if Enum.at(modes, 2) == "1", do: at + 3, else: target

    opcodes
    |> List.replace_at(target, if(a == b, do: 1, else: 0))
    |> parse_opcodes(input, at + 4, nil)
  end

  # terminate
  def operation(opcodes, _, 99, _, _, _) do
    opcodes
  end
end

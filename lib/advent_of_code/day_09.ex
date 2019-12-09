defmodule AdventOfCode.Day09 do
  def part1(input) do
    agent = IntCode.new(input, nil)
    IntCode.set_input(agent, 1)
    {_, result} = IntCode.run(agent)
    result
  end

  def part2(input) do
    agent = IntCode.new(input, nil)
    IntCode.set_input(agent, 2)
    {_, result} = IntCode.run(agent)
    result
  end
end

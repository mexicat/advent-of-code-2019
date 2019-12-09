defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  # @tag :skip
  test "part1" do
    prog1 = [104, 1_125_899_906_842_624, 99]
    assert {_, 1_125_899_906_842_624} = prog1 |> IntCode.new(0) |> IntCode.run()

    prog2 = [1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0]
    assert {_, 1_219_070_632_396_864} = prog2 |> IntCode.new(0) |> IntCode.run()

    prog3 = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]
    # should output all digits in order
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end

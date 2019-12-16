defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  # @tag :skip
  test "part1" do
    pattern = [0, 1, 0, -1]

    assert String.starts_with?(
             part1(80_871_224_585_914_546_619_083_218_645_595),
             "24176176"
           )

    assert String.starts_with?(
             part1(19_617_804_207_202_209_144_916_044_189_917),
             "73745418"
           )

    assert String.starts_with?(
             part1(69_317_163_492_948_606_335_995_924_319_873),
             "52432133"
           )
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end

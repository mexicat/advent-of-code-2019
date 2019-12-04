defmodule AdventOfCode.Day04Test do
  use ExUnit.Case

  import AdventOfCode.Day04

  # @tag :skip
  test "part1" do
    assert valid_password?(111_111)
    assert valid_password?(122_345)
    assert valid_password?(111_123)
    assert not valid_password?(223_450)
    assert not valid_password?(123_789)
    assert not valid_password?(445_179)
  end

  # @tag :skip
  test "part2" do
    assert valid_password_2?(112_233)
    assert not valid_password_2?(123_444)
    assert valid_password_2?(111_122)
  end
end

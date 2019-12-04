defmodule AdventOfCode.Day04 do
  def part1(range) do
    range
    |> Enum.map(&valid_password?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def part2(range) do
    range
    |> Enum.map(&valid_password_2?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def valid_password?(password) do
    increasing?(password) && adjacent_digits?(password)
  end

  def valid_password_2?(password) do
    increasing?(password) && adjacent_digits_2?(password)
  end

  defp adjacent_digits?(password) do
    password |> Integer.to_string() |> String.match?(~r/(.)\1+/)
  end

  defp adjacent_digits_2?(password) do
    password
    |> Integer.digits()
    |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
    |> Enum.any?(fn {_, v} -> v == 2 end)
  end

  defp increasing?(password) do
    [a, b, c, d, e, f] = Integer.digits(password)
    f >= e && e >= d && d >= c && c >= b && b >= a
  end
end

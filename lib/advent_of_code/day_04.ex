defmodule AdventOfCode.Day04 do
  def part1(range) do
    for x <- range do
      Task.async(fn -> valid_password?(x) end)
    end
    |> Enum.map(&Task.await/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def part2(range) do
    for x <- range do
      Task.async(fn -> valid_password_2?(x) end)
    end
    |> Enum.map(&Task.await/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def valid_password?(password) do
    adjacent_digits?(password) && increasing?(password)
  end

  def valid_password_2?(password) do
    adjacent_digits_2?(password) && increasing?(password)
  end

  def adjacent_digits?(password) do
    password |> Integer.to_string() |> String.match?(~r/(.)\1+/)
  end

  def adjacent_digits_2?(password) do
    password
    |> Integer.digits()
    |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
    |> Enum.any?(fn {_, v} -> v == 2 end)
  end

  def increasing?(password) do
    {_, inc} =
      password
      |> Integer.digits()
      |> Enum.reduce_while({0, true}, fn x, {last, _} ->
        case x do
          x when x >= last -> {:cont, {x, true}}
          _ -> {:halt, {nil, false}}
        end
      end)

    inc
  end
end

defmodule AdventOfCode.Day01 do
  def part1(masses) when is_list(masses) do
    masses |> Enum.map(&part1/1) |> Enum.sum()
  end

  def part1(mass) do
    mass |> div(3) |> Kernel.-(2)
  end

  def part2(masses) when is_list(masses) do
    masses |> Enum.map(&part2/1) |> Enum.sum()
  end

  def part2(mass) do
    get_fuel(mass, 0)
  end

  defp get_fuel(mass, acc) when mass < 1, do: acc

  defp get_fuel(mass, acc) do
    case part1(mass) do
      x when x > 0 -> get_fuel(x, acc + x)
      x -> get_fuel(x, acc)
    end
  end
end

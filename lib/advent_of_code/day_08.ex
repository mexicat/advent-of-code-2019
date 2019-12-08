defmodule AdventOfCode.Day08 do
  def part1(input) do
    layer =
      input
      |> String.codepoints()
      |> Enum.chunk_every(25)
      |> Enum.chunk_every(6)
      |> Enum.sort(fn a, b ->
        a |> List.flatten() |> Enum.count(&(&1 == "0")) <
          b |> List.flatten() |> Enum.count(&(&1 == "0"))
      end)
      |> hd()
      |> List.flatten()

    Enum.count(layer, &(&1 == "1")) * Enum.count(layer, &(&1 == "2"))
  end

  def part2(input) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(25 * 6)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&select_pixel/1)
    |> Enum.chunk_every(25)
    |> Enum.map_join("\n", &Enum.join/1)
    |> String.replace("0", " ")
    |> String.replace("1", "■")
    |> IO.puts()
  end

  @doc """
  iex> import AdventOfCode.Day08
  iex> select_pixel [0, 1, 2, 0]
  0
  iex> select_pixel [2, 1, 2, 0]
  1
  iex> select_pixel [2, 2, 1, 0]
  1
  iex> select_pixel [2, 2, 2, 0]
  0
  """
  def select_pixel(pixels) do
    Enum.reduce(pixels, hd(pixels), fn pixel, acc ->
      case acc do
        "2" -> pixel
        x -> x
      end
    end)
  end
end

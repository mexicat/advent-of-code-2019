defmodule AdventOfCode.Day16 do
  def part1(input, pattern \\ [0, 1, 0, -1]) do
    input
    |> Integer.digits()
    |> do_fft(pattern, 100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def part2(input) do
    digits =
      input
      |> Integer.digits()

    offset = digits |> Enum.take(7) |> Enum.join() |> String.to_integer()

    digits
    |> List.duplicate(10000)
    |> List.flatten()
    |> Enum.drop(offset)
    |> do_fft_2(100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def do_fft(signal, pattern, phases) do
    Enum.reduce(1..phases, signal, fn ph, acc ->
      IO.puts(ph)
      apply_phase(acc, pattern)
    end)
  end

  def do_fft_2(signal, phases) do
    Enum.reduce(1..phases, signal, fn ph, signal ->
      IO.puts(ph)

      signal
      |> Enum.reverse()
      |> Enum.scan(0, fn n, acc -> (n + acc) |> abs() |> rem(10) end)
      |> Enum.reverse()
    end)
  end

  def apply_phase(signal, pattern) do
    Enum.map(Enum.with_index(signal), fn {_n, pos} ->
      pattern =
        pattern
        |> pattern_for_pos(pos)
        |> Stream.cycle()
        |> Stream.drop(1)

      signal
      |> Enum.zip(pattern)
      |> Enum.reduce(0, fn {n, operand}, acc ->
        n * operand + acc
      end)
      |> abs()
      |> rem(10)
    end)
  end

  def pattern_for_pos(pattern, 0), do: pattern

  def pattern_for_pos(pattern, pos) do
    for(p <- pattern, do: List.duplicate(p, pos + 1)) |> List.flatten()
  end
end

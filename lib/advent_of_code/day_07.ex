defmodule AdventOfCode.Day07 do
  def part1(program) do
    permutations(0..4)
    |> Enum.map(fn perm ->
      result =
        Enum.reduce(perm, 0, fn phase, signal ->
          agent = IntCode.new(program, phase)
          IntCode.set_input(agent, signal)

          Enum.reduce_while(
            Stream.repeatedly(fn -> IntCode.next(agent) end),
            nil,
            fn
              {:out, intcode}, _ -> {:halt, intcode.input}
              {:stop, intcode}, _ -> {:halt, intcode.input}
              {:cont, _}, acc -> {:cont, acc}
            end
          )
        end)

      {result, perm}
    end)
    |> Enum.sort(fn {a, _}, {b, _} -> a > b end)
    |> hd()
  end

  def part2(program) do
    permutations(5..9)
    |> Enum.map(&find_result(program, &1))
    |> Enum.sort(fn {a, _}, {b, _} -> a > b end)
    |> hd()
  end

  def permutations(range) do
    for a <- range,
        b <- range,
        c <- range,
        d <- range,
        e <- range,
        [a, b, c, d, e] |> Enum.uniq() |> length() == 5,
        do: [a, b, c, d, e],
        into: MapSet.new()
  end

  def find_result(program, perm) do
    amplifiers = Enum.map(perm, fn phase -> IntCode.new(program, phase) end)

    result =
      Enum.reduce_while(Stream.cycle(amplifiers), 0, fn amp, signal ->
        IntCode.set_input(amp, signal)

        Enum.reduce_while(
          Stream.repeatedly(fn -> IntCode.next(amp) end),
          nil,
          fn
            {:out, intcode}, _ -> {:halt, {:out, intcode.input}}
            {:stop, intcode}, _ -> {:halt, {:stop, intcode.input}}
            {:cont, _}, acc -> {:cont, acc}
          end
        )
        |> case do
          {:out, signal} -> {:cont, signal}
          {:stop, signal} -> {:halt, signal}
        end
      end)

    {result, perm}
  end
end

defmodule AdventOfCode.Day13 do
  def part1(program) do
    agent = IntCode.new(program, nil)

    agent
    |> play()
    |> Enum.count(fn {_k, v} -> v == 2 end)
  end

  def part2(program) do
    agent = IntCode.new(program |> List.replace_at(0, 2), nil)
    IntCode.set_input(agent, 0)

    agent
    |> play()
  end

  def play(agent) do
    Enum.reduce_while(
      Stream.repeatedly(fn -> IntCode.next(agent) end),
      {[], %{}},
      fn
        {:out, intcode}, {[0, -1], grid} ->
          IO.puts("score: #{intcode.input}")
          # IO.puts(visualize_grid(grid))
          {:cont, {[], grid}}

        {:out, intcode}, {[y, x], grid} ->
          case intcode.input do
            4 ->
              paddle = grid |> Enum.find(fn {_pos, tile} -> tile == 3 end)

              case paddle do
                nil -> nil
                {{paddle_x, _}, _} when paddle_x > x -> IntCode.set_input(agent, -1)
                {{paddle_x, _}, _} when paddle_x < x -> IntCode.set_input(agent, 1)
                _ -> IntCode.set_input(agent, 0)
              end

            _ ->
              nil
          end

          grid = Map.put(grid, {x, y}, intcode.input)
          # IO.puts(visualize_grid(grid))

          {:cont, {[], grid}}

        {:out, intcode}, {op, grid} ->
          {:cont, {[intcode.input | op], grid}}

        {:stop, _}, {_, grid} ->
          {:halt, grid}

        {:cont, _}, acc ->
          {:cont, acc}
      end
    )
  end

  def visualize_grid(grid) do
    max_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()

    for y <- 0..max_y do
      for x <- 0..max_x do
        case Map.get(grid, {x, y}) do
          1 -> "|"
          2 -> "#"
          3 -> "_"
          4 -> "@"
          _ -> " "
        end
      end
      |> Kernel.++([y])
      |> Enum.join()
    end
    |> Enum.join("\n")
  end
end

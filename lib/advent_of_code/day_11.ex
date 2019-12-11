defmodule AdventOfCode.Day11 do
  def part1(program) do
    agent = IntCode.new(program, nil)
    IntCode.set_input(agent, 0)

    agent
    |> walk_grid()
    |> map_size()
  end

  def part2(program) do
    agent = IntCode.new(program, nil)
    IntCode.set_input(agent, 1)

    agent
    |> walk_grid()
    |> visualize_grid()
    |> IO.puts()
  end

  def walk_grid(agent) do
    Enum.reduce_while(
      Stream.repeatedly(fn -> IntCode.next(agent) end),
      {:up, {0, 0}, true, %{{0, 0} => 0}},
      fn
        {:out, intcode}, {dir, pos, true, grid} ->
          # paint
          grid = Map.put(grid, pos, intcode.input)
          {:cont, {dir, pos, nil, grid}}

        {:out, intcode}, {dir, pos, nil, grid} ->
          # move
          new_dir = change_direction(dir, intcode.input)
          new_pos = move(pos, new_dir)
          new_color = Map.get(grid, new_pos, 0)
          IntCode.set_input(agent, new_color)
          {:cont, {new_dir, new_pos, true, grid}}

        {:stop, _}, {_, _, _, grid} ->
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
          1 -> "#"
          _ -> " "
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end

  def change_direction(dir, to) do
    clockwise = %{up: :right, right: :down, down: :left, left: :up}
    counterclockwise = clockwise |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

    case to do
      1 -> Map.get(clockwise, dir)
      0 -> Map.get(counterclockwise, dir)
    end
  end

  def move({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :right -> {x + 1, y}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
    end
  end
end

defmodule AdventOfCode.Day15 do
  def part1(program) do
    initial = IntCodeFun.new(program, nil)

    search(initial, {0, 0}, 0, %{visited: %{}, walls: MapSet.new(), oxygen: nil})
  end

  def part2(program) do
    state = program |> part1()
    visited = state.visited |> Map.new(fn {k, _} -> {k, " "} end)
    walls = state.walls |> Map.new(fn pos -> {pos, "#"} end)

    grid =
      walls
      |> Map.merge(visited)
      |> Map.put(state.oxygen, "O")

    {_, steps} = fill(grid, state.oxygen, 0, 0)
    steps
  end

  def fill(grid, pos, steps, max_steps) do
    Enum.reduce(1..4, {grid, max_steps}, fn dir, {grid, max_steps} ->
      with new_pos <- move(pos, dir),
           true <- Map.get(grid, new_pos) == " " do
        fill(Map.put(grid, new_pos, "O"), new_pos, steps + 1, max(max_steps, steps + 1))
      else
        false ->
          {grid, max(max_steps, steps)}
      end
    end)
  end

  def search(intcode, pos, steps, state = %{visited: visited, walls: walls}) do
    Enum.reduce(1..4, state, fn dir, state ->
      with new_pos <- move(pos, dir),
           true <- not Enum.member?(walls, new_pos),
           true <- not Map.has_key?(visited, new_pos) do
        {:out, intcode} =
          intcode
          |> IntCodeFun.set_input(dir)
          |> IntCodeFun.run_until_output()

        case intcode.input do
          0 ->
            %{state | walls: MapSet.put(state.walls, new_pos)}

          # add to visited and recursively search there
          1 ->
            search(intcode, new_pos, steps + 1, %{
              state
              | visited: Map.put(state.visited, new_pos, intcode)
            })

          # found oxygen
          2 ->
            IO.puts(steps + 1)
            %{state | oxygen: new_pos}
        end
      else
        false -> state
      end
    end)
  end

  def move({x, y}, 1), do: {x, y + 1}
  def move({x, y}, 2), do: {x, y - 1}
  def move({x, y}, 3), do: {x - 1, y}
  def move({x, y}, 4), do: {x + 1, y}
end

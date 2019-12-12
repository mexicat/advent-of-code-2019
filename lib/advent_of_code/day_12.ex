defmodule AdventOfCode.Day12 do
  def part1(input, steps) do
    input
    |> parse_input()
    |> do_steps(steps)
    |> calc_total_energy()
  end

  def part2(input) do
    %{x: x, y: y, z: z} =
      input
      |> parse_input()
      |> find_repeating()

    x |> lcm(y) |> lcm(z)
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row ->
      [pos_x, pos_y, pos_z] =
        row
        |> String.replace(~r/[^0-9\s-]/, "")
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)

      %{pos: %{x: pos_x, y: pos_y, z: pos_z}, vel: %{x: 0, y: 0, z: 0}}
    end)
  end

  def apply_gravity(moons) do
    moons
    |> Enum.reduce([], fn moon, acc ->
      vel = %{
        x: calc_new_velocity(moon, :x, moons),
        y: calc_new_velocity(moon, :y, moons),
        z: calc_new_velocity(moon, :z, moons)
      }

      [%{moon | vel: vel} | acc]
    end)
    |> Enum.reverse()
  end

  def apply_velocity(moons) do
    moons
    |> Enum.reduce([], fn moon, acc ->
      pos = %{x: moon.pos.x + moon.vel.x, y: moon.pos.y + moon.vel.y, z: moon.pos.z + moon.vel.z}

      [%{moon | pos: pos} | acc]
    end)
    |> Enum.reverse()
  end

  def do_steps(moons, steps) do
    Enum.reduce(1..steps, moons, fn _, moons ->
      moons
      |> apply_gravity()
      |> apply_velocity()
    end)
  end

  def calc_new_velocity(moon, axis, moons) do
    Map.get(moon.vel, axis) +
      Enum.count(moons, &(Map.get(&1.pos, axis) > Map.get(moon.pos, axis))) -
      Enum.count(moons, &(Map.get(&1.pos, axis) < Map.get(moon.pos, axis)))
  end

  def calc_total_energy(moons) do
    moons
    |> Enum.map(&calc_energy/1)
    |> Enum.sum()
  end

  defp calc_energy(moon) do
    (abs(moon.pos.x) + abs(moon.pos.y) + abs(moon.pos.z)) *
      (abs(moon.vel.x) + abs(moon.vel.y) + abs(moon.vel.z))
  end

  def find_repeating(moons) do
    moons
    |> Stream.iterate(&(&1 |> apply_gravity() |> apply_velocity()))
    |> Enum.reduce_while(%{x: MapSet.new(), y: MapSet.new(), z: MapSet.new()}, fn moons, acc ->
      acc =
        acc
        |> Enum.map(fn
          {axis, n} when is_integer(n) ->
            {axis, n}

          {axis, set} ->
            points = for m <- moons, do: {Map.get(m.pos, axis), Map.get(m.vel, axis)}

            if MapSet.member?(set, points),
              do: {axis, MapSet.size(set)},
              else: {axis, MapSet.put(set, points)}
        end)
        |> Map.new()

      if is_integer(acc.x) && is_integer(acc.y) && is_integer(acc.z),
        do: {:halt, acc},
        else: {:cont, acc}
    end)
  end

  defp gcd(a, 0), do: a
  defp gcd(0, b), do: b
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(0, 0), do: 0
  defp lcm(a, b), do: div(a * b, gcd(a, b))
end

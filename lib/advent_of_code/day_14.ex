defmodule AdventOfCode.Day14 do
  defmodule Factory do
    def start() do
      {:ok, pid} = Agent.start_link(fn -> %{} end)
      pid
    end

    def close(agent) do
      Agent.stop(agent)
    end

    def get(agent, chemical, default \\ 0) do
      Agent.get(agent, fn state -> Map.get(state, chemical, default) end)
    end

    def put(agent, chemical, n) do
      Agent.update(agent, fn state -> Map.put(state, chemical, n) end)
    end
  end

  def part1(input) do
    factory = Factory.start()

    mappings =
      input
      |> String.split("\n")
      |> Enum.reduce(%{}, &parse_line/2)

    make_chemical(1, "FUEL", mappings, factory, 0)
  end

  def part2(input) do
  end

  def parse_line(line, acc) do
    [{to_chem, to_amt} | from] =
      line
      |> String.split(~r/,\s|\s=>\s/)
      |> Enum.map(fn v ->
        [n, element] = String.split(v)
        {element, String.to_integer(n)}
      end)
      |> Enum.reverse()

    Map.put(acc, to_chem, {to_amt, from})
  end

  def make_chemical(amt, chemical, mappings, deposit, ores) do
    case Factory.get(deposit, chemical, 0) do
      n when n > amt ->
        Factory.put(deposit, chemical, n - amt)
        ores

      n ->
        needed = amt - n
        {min, ingredients} = Map.get(mappings, chemical)
        to_create = ceil(needed / min) * min
        repeats = ceil(needed / min)
        ingredients = ingredients |> Enum.map(fn {c, a} -> {c, a * repeats} end)
        Factory.put(deposit, chemical, to_create - needed)

        Enum.reduce(ingredients, ores, fn
          {"ORE", a}, ores -> ores + a
          {c, a}, ores -> make_chemical(a, c, mappings, deposit, ores)
        end)
    end
  end
end

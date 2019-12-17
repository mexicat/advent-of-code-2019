defmodule IntCodeFun do
  @enforce_keys [:phase, :input, :opcodes]
  defstruct [:phase, :input, :opcodes, at: 0, rel_base: 0, output: []]

  def new(opcodes, phase) do
    %__MODULE__{phase: phase, input: [], opcodes: opcodes}
  end

  def set_input(intcode, input) when is_list(input) do
    Map.put(intcode, :input, intcode.input ++ input)
  end

  def set_input(intcode, input) do
    Map.put(intcode, :input, intcode.input ++ [input])
  end

  def run(intcode) do
    Stream.iterate({:cont, intcode}, fn
      {:out, intcode} ->
        next(intcode)

      {:cont, intcode} ->
        next(intcode)

      {:stop, intcode} ->
        IO.inspect(intcode)
        {:stop, intcode}
    end)
    |> Enum.find(&(elem(&1, 0) == :stop))
  end

  def run_until_output(intcode) do
    Stream.iterate({:cont, intcode}, fn
      {:out, intcode} ->
        {:out, intcode}

      {:cont, intcode} ->
        next(intcode)

      {:stop, intcode} ->
        IO.inspect(intcode)
        {:stop, intcode}
    end)
    |> Enum.find(&(elem(&1, 0) == :out))
  end

  def next(intcode = %{opcodes: opcodes, at: at}) do
    to_parse = Enum.drop(opcodes, at)
    [op | args] = to_parse
    {modes, operation} = identify_op(op)

    case operation do
      1 ->
        add(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode),
          at(Enum.at(args, 2), Enum.at(modes, 2, 0), intcode)
        )

      2 ->
        multiply(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode),
          at(Enum.at(args, 2), Enum.at(modes, 2, 0), intcode)
        )

      3 ->
        save(intcode, at(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode))

      4 ->
        output(intcode, target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode))

      5 ->
        jump_if_true(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode)
        )

      6 ->
        jump_if_false(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode)
        )

      7 ->
        less_than(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode),
          at(Enum.at(args, 2), Enum.at(modes, 2, 0), intcode)
        )

      8 ->
        equals(
          intcode,
          target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode),
          target(Enum.at(args, 1), Enum.at(modes, 1, 0), intcode),
          at(Enum.at(args, 2), Enum.at(modes, 2, 0), intcode)
        )

      9 ->
        rel_base_offset(intcode, target(Enum.at(args, 0), Enum.at(modes, 0, 0), intcode))

      99 ->
        terminate(intcode)
    end
  end

  def identify_op(op) do
    operation = rem(op, 100)
    modes = op |> div(100) |> Integer.digits() |> Enum.reverse()
    {modes, operation}
  end

  def add(intcode, a, b, c) do
    opcodes = replace_at(intcode.opcodes, c, a + b)
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def multiply(intcode, a, b, c) do
    opcodes = replace_at(intcode.opcodes, c, a * b)
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def save(intcode, a) do
    [input | rest_of_input] = intcode.input

    opcodes =
      replace_at(
        intcode.opcodes,
        a,
        input
      )

    {:cont, %{intcode | opcodes: opcodes, phase: nil, input: rest_of_input, at: intcode.at + 2}}
  end

  def output(intcode, a) do
    # IO.puts("output: #{a}")
    {:out, %{intcode | output: [a | intcode.output], at: intcode.at + 2}}
  end

  def jump_if_true(intcode, a, b) do
    at = if a != 0, do: b, else: intcode.at + 3
    {:cont, %{intcode | at: at}}
  end

  def jump_if_false(intcode, a, b) do
    at = if a == 0, do: b, else: intcode.at + 3
    {:cont, %{intcode | at: at}}
  end

  def less_than(intcode, a, b, c) do
    opcodes = replace_at(intcode.opcodes, c, if(a < b, do: 1, else: 0))
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def equals(intcode, a, b, c) do
    opcodes = replace_at(intcode.opcodes, c, if(a == b, do: 1, else: 0))
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def rel_base_offset(intcode, a) do
    {:cont, %{intcode | rel_base: intcode.rel_base + a, at: intcode.at + 2}}
  end

  def terminate(intcode) do
    {:stop, intcode}
  end

  def target(arg, mode, intcode) do
    case mode do
      1 -> arg
      2 -> Enum.at(intcode.opcodes, arg + intcode.rel_base, 0)
      0 -> Enum.at(intcode.opcodes, arg, 0)
    end
  end

  def at(pos, mode, intcode) do
    case mode do
      0 -> pos
      2 -> pos + intcode.rel_base
      x -> raise ArgumentError, "invalid position #{x}"
    end
  end

  def replace_at(list, index, value) do
    list =
      cond do
        length(list) < index + 1 -> list ++ List.duplicate(0, index - length(list) + 1)
        true -> list
      end

    List.replace_at(list, index, value)
  end
end

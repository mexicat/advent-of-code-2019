defmodule IntCode do
  alias __MODULE__
  use Agent

  @enforce_keys [:phase, :input, :opcodes]
  defstruct [:phase, :input, :opcodes, at: 0]

  def new(opcodes, phase) do
    {:ok, pid} = Agent.start_link(fn -> %IntCode{phase: phase, input: 0, opcodes: opcodes} end)

    pid
  end

  def set_input(agent, input) do
    Agent.update(agent, fn intcode -> %{intcode | input: input} end)
  end

  def next(agent) do
    intcode = Agent.get(agent, & &1)
    to_parse = Enum.drop(intcode.opcodes, intcode.at)
    [op | args] = to_parse
    {modes, operation} = identify_op(op)

    {status, intcode} =
      case operation do
        1 -> add(intcode, args |> Enum.slice(0..2) |> target(modes, intcode.opcodes))
        2 -> multiply(intcode, args |> Enum.slice(0..2) |> target(modes, intcode.opcodes))
        3 -> save(intcode, Enum.at(args, 0))
        4 -> output(intcode, Enum.at(args, 0))
        5 -> jump_if_true(intcode, args |> Enum.slice(0..1) |> target(modes, intcode.opcodes))
        6 -> jump_if_false(intcode, args |> Enum.slice(0..1) |> target(modes, intcode.opcodes))
        7 -> less_than(intcode, args |> Enum.slice(0..2) |> target(modes, intcode.opcodes))
        8 -> equals(intcode, args |> Enum.slice(0..2) |> target(modes, intcode.opcodes))
        99 -> terminate(intcode)
      end

    Agent.update(agent, fn _ -> intcode end)
    # IO.inspect(Agent.get(agent, & &1))
    {status, intcode}
  end

  def identify_op(op) do
    operation = rem(op, 100)
    modes = op |> div(100) |> Integer.digits() |> Enum.reverse()
    {modes, operation}
  end

  def add(intcode, [a, b, c]) do
    opcodes = List.replace_at(intcode.opcodes, c, a + b)
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def multiply(intcode, [a, b, c]) do
    opcodes = List.replace_at(intcode.opcodes, c, a * b)
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def save(intcode, a) do
    opcodes =
      List.replace_at(
        intcode.opcodes,
        a,
        if(intcode.phase, do: intcode.phase, else: intcode.input)
      )

    {:cont, %{intcode | opcodes: opcodes, phase: nil, at: intcode.at + 2}}
  end

  def output(intcode, a) do
    out = Enum.at(intcode.opcodes, a)
    # IO.puts("Output: #{out}")
    {:out, %{intcode | input: out, at: intcode.at + 2}}
  end

  def jump_if_true(intcode, [a, b]) do
    at = if a != 0, do: b, else: intcode.at + 3
    {:cont, %{intcode | at: at}}
  end

  def jump_if_false(intcode, [a, b]) do
    at = if a == 0, do: b, else: intcode.at + 3
    {:cont, %{intcode | at: at}}
  end

  def less_than(intcode, [a, b, c]) do
    opcodes = List.replace_at(intcode.opcodes, c, if(a < b, do: 1, else: 0))
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def equals(intcode, [a, b, c]) do
    opcodes = List.replace_at(intcode.opcodes, c, if(a == b, do: 1, else: 0))
    {:cont, %{intcode | opcodes: opcodes, at: intcode.at + 4}}
  end

  def terminate(intcode) do
    {:stop, intcode}
  end

  def target(args, modes, opcodes) do
    [p1, p2 | rest] = args

    params =
      [p1, p2]
      |> Enum.with_index()
      |> Enum.map(fn {arg, i} ->
        case Enum.at(modes, i, 0) do
          1 -> arg
          0 -> Enum.at(opcodes, arg)
        end
      end)

    params ++ rest
  end
end

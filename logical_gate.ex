# Your code here!
defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
end

defmodule NbitRogicalGate do
  def nbit_converter(inputs, gate_func) do
    Enum.map(inputs, fn row ->
        case Enum.count(row) == 2 do
          true ->
            [x, y] = row
            gate_func.(x, y)
          false ->
            [x] = row
            gate_func.(x)
        end
      end
    )
  end
  def nand(inputs), do: nbit_converter(inputs, &RogicalGate.nand/2)
  def not_(inputs), do: nbit_converter(inputs, &RogicalGate.not_/1)
  def or_(inputs), do: nbit_converter(inputs, &RogicalGate.or_/2)
  def and_(inputs), do: nbit_converter(inputs, &RogicalGate.and_/2)
  def xor_(inputs), do: nbit_converter(inputs, &RogicalGate.xor_/2)
end

info = [
  [0, 0],
  [1, 0],
  [0, 1],
  [1, 1],
]

info_for_not = [
  [1],
  [0]
]

res = [
  NbitRogicalGate.nand(info),
  NbitRogicalGate.not_(info_for_not),
  NbitRogicalGate.or_(info),
  NbitRogicalGate.and_(info),
  NbitRogicalGate.xor_(info),
]

Enum.map(res, &(IO.inspect(&1)))


defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
end

defmodule NbitRogicalGate do
  def nbit_converter(inputs, gate_func) do
    Enum.map(inputs, fn row ->
        case Enum.count(row) == 2 do
          true ->
            [x, y] = row
            gate_func.(x, y)
          false ->
            [x] = row
            gate_func.(x)
        end
      end
    )
  end
  def nand(inputs), do: nbit_converter(inputs, &RogicalGate.nand/2)
  def not_(inputs), do: nbit_converter(inputs, &RogicalGate.not_/1)
  def or_(inputs), do: nbit_converter(inputs, &RogicalGate.or_/2)
  def and_(inputs), do: nbit_converter(inputs, &RogicalGate.and_/2)
  def xor_(inputs), do: nbit_converter(inputs, &RogicalGate.xor_/2)
end

sum_ = fn x, y -> RogicalGate.xor_(x,y) end
carry_ = fn x, y -> RogicalGate.and_(x,y) end
half_adder = fn x, y -> {carry_.(x,y), sum_.(x,y)} end

half_adder_test = [
  half_adder.(0, 0) == {0, 0},
  half_adder.(0, 1) == {0, 1},
  half_adder.(1, 0) == {0, 1},
  half_adder.(1, 1) == {1, 0}
]

IO.inspect(half_adder_test)


all_adder = fn x, y, z ->
  {res1_x, res1_y} = half_adder.(x, y)
  {res2_x, res2_y} = half_adder.(res1_y, z)
  {RogicalGate.or_(res1_x, res2_x), res2_y}
end

all_adder_test = [
  all_adder.(0,0,0) == {0,0},
  all_adder.(0,1,0) == {0,1},
  all_adder.(1,0,0) == {0,1},
  all_adder.(1,1,0) == {1,0},
  all_adder.(0,0,1) == {0,1},
  all_adder.(0,1,1) == {1,0},
  all_adder.(1,0,1) == {1,0},
  all_adder.(1,1,1) == {1,1},
]

IO.inspect(all_adder_test)

defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
end

defmodule NbitRogicalGate do
  def nbit_converter(inputs, gate_func) do
    Enum.map(inputs, fn row ->
        case Enum.count(row) == 2 do
          true ->
            [x, y] = row
            gate_func.(x, y)
          false ->
            [x] = row
            gate_func.(x)
        end
      end
    )
  end
  def nand(inputs), do: nbit_converter(inputs, &RogicalGate.nand/2)
  def not_(inputs), do: nbit_converter(inputs, &RogicalGate.not_/1)
  def or_(inputs), do: nbit_converter(inputs, &RogicalGate.or_/2)
  def and_(inputs), do: nbit_converter(inputs, &RogicalGate.and_/2)
  def xor_(inputs), do: nbit_converter(inputs, &RogicalGate.xor_/2)
end

sum_ = fn x, y -> RogicalGate.xor_(x,y) end
carry_ = fn x, y -> RogicalGate.and_(x,y) end
half_adder = fn x, y -> {carry_.(x,y), sum_.(x,y)} end

half_adder_test = [
  half_adder.(0, 0) == {0, 0},
  half_adder.(0, 1) == {0, 1},
  half_adder.(1, 0) == {0, 1},
  half_adder.(1, 1) == {1, 0}
]

IO.inspect(half_adder_test)


all_adder = fn x, y, z ->
  {res1_x, res1_y} = half_adder.(x, y)
  {res2_x, res2_y} = half_adder.(res1_y, z)
  {RogicalGate.or_(res1_x, res2_x), res2_y}
end

all_adder_test = [
  all_adder.(0,0,0) == {0,0},
  all_adder.(0,1,0) == {0,1},
  all_adder.(1,0,0) == {0,1},
  all_adder.(1,1,0) == {1,0},
  all_adder.(0,0,1) == {0,1},
  all_adder.(0,1,1) == {1,0},
  all_adder.(1,0,1) == {1,0},
  all_adder.(1,1,1) == {1,1},
]

IO.inspect(all_adder_test)

n_bit_adder = fn [a0, b0], [a1, b1], [a2, b2] ->
  {c0, s0} = half_adder.(a0, b0)
  {c1, s1} = all_adder.(a1, b1, c0)
  {c2, s2} = all_adder.(a2, b2, c1)
  {c2, s2, s1, s0}
end

IO.inspect(n_bit_adder.([1,1], [1,1], [1,1]))


defmodule NbitAdder do
  def sum_(x, y), do: RogicalGate.xor_(x,y)
  def carry_(x, y), do: RogicalGate.and_(x,y)
  def half_adder(x, y), do: {carry_(x,y), sum_(x,y)}
  def full_adder(x, y, z) do
    {res1_x, res1_y} = half_adder(x, y)
    {res2_x, res2_y} = half_adder(res1_y, z)
    {RogicalGate.or_(res1_x, res2_x), res2_y}
  end
  def nbit_adder([]), do: :error
  def nbit_adder([[]]), do: :error
  def nbit_adder([[a0, b0] | tail]) do
    {c0, s0} = half_adder(a0, b0)
    _nbit_adder(tail, c0, [s0])
  end

  defp _nbit_adder([], carry, accum), do: [carry] ++ accum
  defp _nbit_adder([[a1, b1] | tail], carry, accum) do
    {c0, s0} = full_adder(a1, b1, carry)
    _nbit_adder(tail, c0, [s0] ++ accum)
  end
end

res = NbitAdder.nbit_adder([[]])
IO.inspect(res)

res = NbitAdder.nbit_adder([[1,1], [1,1], [1,1], [1,1]])
IO.inspect(res)

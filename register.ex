defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
  def mux([x, y], sel) do
    not_sel = not_(sel)
    or_(and_(x, not_sel), and_(y, sel))
  end
  def dmux(x, sel) do
    not_sel = not_(sel)
    {and_(x, not_sel), and_(x, sel)}
  end
  def dff(_, 0), do: 0
  def dff([], _), do: 0
  # def dff(in_, _) when length(in_) == 1, do: 0
  def dff(_, 1), do: 0
  def dff(in_, t), do: Enum.at(in_, t - 2)
end

# register = []
# res = Enum.reduce([[1,1],[1,1],[0,1]], [], fn [x, sel], acc ->
#   before = Enum.at(register, -1, 0)
#   IO.puts("--> before #{before}")
#   muxout = RogicalGate.mux([before, x], sel)
#   IO.puts("--> muxout #{muxout}")
#   register = register ++ [muxout]
#   dffout = RogicalGate.dff(register, Enum.count(register))
#   IO.puts("--> dffout #{dffout}")
#   [RogicalGate.or_(0, dffout)] ++ acc
# end)

# IO.inspect(res)
# IO.inspect(register)
# リストは参照されないってのwww

defmodule Bit do
  def bit(inputs), do: _bit(inputs, [], [])
  def _bit([], _, acc), do: acc
  def _bit([[x, sel] | tail], register, acc) do
    before = Enum.at(register, -1, 0)
    muxout = RogicalGate.mux([before, x], sel)
    register = register ++ [muxout]
    dffout = RogicalGate.dff(register, Enum.count(register))
    out = RogicalGate.or_(0, dffout)
    _bit(tail, register, acc ++ [out])
  end
end

res = Bit.bit([[1,1],[0,1],[0,1],[1,0]])
IO.inspect(res)

# register = []
# muxout = RogicalGate.mux([0, 1], 1)
# register = register ++ [muxout]
# IO.inspect(register)

# dffout = RogicalGate.dff(register, 1)
# IO.puts(dffout)
# out = RogicalGate.or_(0, dffout)
# IO.puts(out)


# before = Enum.at(register, -1)
# IO.puts(before)
# muxout = RogicalGate.mux([before, 1], 1)
# register = register ++ [muxout]
# IO.inspect(register)

# dffout = RogicalGate.dff(register, 2)
# IO.puts(dffout)
# out = RogicalGate.or_(0, dffout)
# IO.puts(out)


# before = Enum.at(register, -1)
# IO.puts(before)
# muxout = RogicalGate.mux([before, 0], 1)
# register = register ++ [muxout]
# IO.inspect(register)

# dffout = RogicalGate.dff(register, 3)
# IO.puts(dffout)
# out = RogicalGate.or_(0, dffout)
# IO.puts(out)

# --------------------------------------------
# convert nbit Regsiter
# --------------------------------------------

defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
  def mux([x, y], sel) do
    not_sel = not_(sel)
    or_(and_(x, not_sel), and_(y, sel))
  end
  def dmux(x, sel) do
    not_sel = not_(sel)
    {and_(x, not_sel), and_(x, sel)}
  end
  def dff(_, 0), do: 0
  def dff([], _), do: 0
  # def dff(in_, _) when length(in_) == 1, do: 0
  def dff(_, 1), do: 0
  def dff(in_, t), do: Enum.at(in_, t - 2)
end


defmodule Bit do
  def bit(inputs), do: _bit(inputs, [], [])
  def _bit([], _, acc), do: acc
  def _bit([[x, sel] | tail], register, acc) do
    before = Enum.at(register, -1, 0)
    muxout = RogicalGate.mux([before, x], sel)
    register = register ++ [muxout]
    dffout = RogicalGate.dff(register, Enum.count(register))
    out = RogicalGate.or_(0, dffout)
    _bit(tail, register, acc ++ [out])
  end
  def register(inputs) do
    res = Enum.map(inputs, fn [row, sel] ->
            Enum.map(row, fn x -> [x, sel] end)
          end)
    Enum.map(res, fn data -> Bit.bit(data) end)
  end
end

res = Bit.bit([[1,1],[0,1],[0,1],[1,0]])
IO.inspect(res)

inputs = [[[1,0,1,0], 1], [[0,0,1,0], 0], [[1,1,1,0], 1], [[0,0,0,0], 0]]
res = Enum.map(inputs, fn [row, sel] ->
        Enum.map(row, fn x -> [x, sel] end)
      end)
IO.inspect(res)

reses = Enum.map(res, fn data -> Bit.bit(data) end)
IO.inspect(reses)

inputs = [[[1,0,1,0], 1], [[0,0,1,0], 0], [[1,1,1,0], 1], [[0,0,0,0], 0]]
re = Bit.register(inputs)
IO.inspect(re)


# --------------------------------------------
# add register and memory
# --------------------------------------------

defmodule RogicalGate do
  def nand(1, 1), do: 0
  def nand(_x, _y), do: 1
  def or_(x, y), do: nand(nand(x, x), nand(y, y))
  def not_(x), do: nand(x, x)
  def and_(x, y), do: not_(nand(x,y))
  def xor_(x, y), do: or_(and_(x,not_(y)), and_(not_(x),y))
  def mux([x, y], sel) do
    not_sel = not_(sel)
    or_(and_(x, not_sel), and_(y, sel))
  end
  def dmux(x, sel) do
    not_sel = not_(sel)
    {and_(x, not_sel), and_(x, sel)}
  end
  def dff(_, 0), do: 0
  def dff([], _), do: 0
  # def dff(in_, _) when length(in_) == 1, do: 0
  def dff(_, 1), do: 0
  def dff(in_, t), do: Enum.at(in_, t - 2)
end

defmodule NbitRogicalGate do
  def nbit_converter(inputs, gate_func), do: Enum.map(inputs, fn [x, y] -> gate_func.(x, y) end)
  def nbit_not(inputs, gate_func), do: Enum.map(inputs, fn x -> gate_func.(x) end)
  def nbit_mux(inputs, gate_func), do: Enum.map(inputs, fn [[x,y], sel] -> gate_func.([x,y], sel)  end)

  def nand(inputs), do: nbit_converter(inputs, &RogicalGate.nand/2)
  def not_(inputs), do: nbit_not(inputs, &RogicalGate.not_/1)
  def or_(inputs), do: nbit_converter(inputs, &RogicalGate.or_/2)
  def and_(inputs), do: nbit_converter(inputs, &RogicalGate.and_/2)
  def xor_(inputs), do: nbit_converter(inputs, &RogicalGate.xor_/2)

  def mux(inputs), do: nbit_mux(inputs, &RogicalGate.mux/2)
  def dmux(inputs), do: nbit_converter(inputs, &RogicalGate.dmux/2)
end

defmodule MultiDmux do
  def lst_converter(x, y), do: Enum.map(Enum.zip(x, y), fn {a, b} -> [a, b] end)
  def lst_converter(x, y, sel), do: Enum.map(Enum.zip(x, y), fn {a, b} -> [[a, b], sel] end)
  def dmux4way(x, [sel1, sel2]) do
    {out1, out2} = RogicalGate.dmux(x, sel1)
    {a, b} = RogicalGate.dmux(out1, sel2)
    {c, d} = RogicalGate.dmux(out2, sel2)
    {a, b, c, d}
  end
  def dmux8way(x, [sel1, sel2, sel3]) do
    {out1, out2, out3, out4} = dmux4way(x, [sel1, sel2])
    {a, b} = RogicalGate.dmux(out1, sel3)
    {c, d} = RogicalGate.dmux(out2, sel3)
    {e, f} = RogicalGate.dmux(out3, sel3)
    {g, h} = RogicalGate.dmux(out4, sel3)
    {a, b, c, d, e, f, g, h}
  end
  def mux4wayNbit(a, b, c, d, [sel1, sel2]) do
    ab_lst = lst_converter(a, b, sel2)
    ab = NbitRogicalGate.mux(ab_lst)
    cd_lst = lst_converter(c, d, sel2)
    cd = NbitRogicalGate.mux(cd_lst)
    out_lst = lst_converter(ab, cd, sel1)
    NbitRogicalGate.mux(out_lst)
  end
  def mux8wayNbit(a, b, c, d, e, f, g, h, [sel1, sel2, sel3]) do
    abcd = mux4wayNbit(a, b, c, d, [sel2, sel3])
    efgh = mux4wayNbit(e, f, g, h, [sel2, sel3])
    out_lst = lst_converter(abcd, efgh, sel1)
    NbitRogicalGate.mux(out_lst)
  end
end

defmodule Bit do
  def bit(inputs), do: _bit(inputs, [], 0)
  def _bit([], _, acc), do: acc
  def _bit([[x, sel] | tail], register, acc) do
    # before = Enum.at(register, -1, 0)
    muxout = RogicalGate.mux([acc, x], sel)
    register = register ++ [muxout]
    dffout = RogicalGate.dff(register, Enum.count(register))
    out = RogicalGate.or_(0, dffout)
    _bit(tail, register, out)
  end
  def register(inputs) do
    res = Enum.map(inputs, fn [row, sel] ->
            Enum.map(row, fn x -> [x, sel] end)
          end)
    Enum.reduce(res, [], fn data, acc ->
    # IO.puts("--->")
    # IO.inspect(data)
    # IO.inspect(Bit.bit(data))
    acc ++ [Bit.bit(data)] end)
  end
end

inputs = [
  [[1,0,1,0], 1],
  [[0,0,1,0], 0],
  [[1,1,1,0], 1],
  [[0,0,0,0], 0]
]
res = Bit.register(inputs)
IO.inspect(res)

# res = MultiDmux.dmux4way(1, [1, 0])
# IO.inspect(res)

# res = MultiDmux.dmux8way(1, [1, 1, 1])
# IO.inspect(res)

# res = MultiDmux.mux4wayNbit([1,1,1,1], [1,0,1,0], [0,1,0,1], [0,0,0,0], [0,1])
# IO.inspect(res)

# res = MultiDmux.mux8wayNbit(
#   [1,1,1,1],
#   [1,0,1,0],
#   [0,1,0,1],
#   [0,0,0,0],
#   [0,0,0,1],
#   [0,0,1,0],
#   [0,1,0,0],
#   [1,0,0,0],
#   [1,1,1]
# )
# IO.inspect(res)

defmodule RAM do
  # def converter(x, y), do: Enum.map(Enum.zip(x, y), fn {a, b} -> [[a], b] end)
  def converter(lst, sel), do: Enum.map(lst, fn x -> [[x], sel] end)
  def ram8(inputs), do: _ram8(inputs, [])
  def _ram8([], acc), do: acc
  def _ram8([[input, load, address] | tail], acc) do
    {a,b,c,d,e,f,g,h} = MultiDmux.dmux8way(load, address)
    IO.puts("---> ")
    rout1 = Bit.register([[input, a]])
    rout2 = Bit.register([[input, b]])
    rout3 = Bit.register([[input, c]])
    rout4 = Bit.register([[input, d]])
    rout5 = Bit.register([[input, e]])
    rout6 = Bit.register([[input, f]])
    rout7 = Bit.register([[input, g]])
    rout8 = Bit.register([[input, h]])
    IO.inspect(rout1)
    out = MultiDmux.mux8wayNbit(
            rout1,
            rout2,
            rout3,
            rout4,
            rout5,
            rout6,
            rout7,
            rout8,
            address
          )
    _ram8(tail, acc ++ [out])
  end
end

res = RAM.ram8([[[1,1,0,0,1,1,1,1], 1, [0,0,0]], [[1,1,0,0,1,1,0,1], 1, [0,0,0]]])
IO.inspect(res)

"""
@color
M=0

(LOOP)
	@SCREEN
	D=A
	@pixels
	M=D

	@KBD
	D=M
	@BLACK
	D;JGT

	@color
	M=0
	@COLOR_SCREEN
	0;JMP

	(BLACK)
		@color
		M=1

	(COLOR_SCREEN)
		@color
		D=M
		@pixels
		A=M
		M=D

		@pixels
		M=M+1
		D=M

		@24576
		D=D-A
		@COLOR_SCREEN
		D;JLT
@LOOP
0;JMP
"""


# Stream.transform のサンプル
defmodule UtilString do
  def suntil(str, target) do
    str_lst = String.codepoints(str)
    target_index = Enum.find_index(str_lst, &(&1 == target))
    case target_index do
      nil -> str
      0 -> Enum.slice(str_lst, 0..target_index) |> Enum.join()
      _ -> Enum.slice(str_lst, 0..target_index-1) |> Enum.join()
    end
  end

  def until(str, target) do
    String.codepoints(str)
    |> Stream.transform("", fn x, acc ->
      if x == target do
        {:halt, nil}
      else
        {[acc <> x], acc <> x}
      end
    end)
    |> Enum.to_list()
  end
end

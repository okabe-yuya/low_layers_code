# 1bit論理ゲート
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
end


# Nbit論理ゲート
defmodule NbitRogicalGate do
  # [x,y]のような入力を2つ受ける回路の変換関数
  def nbit_converter(inputs, gate_func), do: Enum.map(inputs, fn [x, y] -> gate_func.(x, y) end)
  # [x]のような入力を1つ受ける回路(not)の変換関数
  def nbit_not(inputs, gate_func), do: Enum.map(inputs, fn x -> gate_func.(x) end)
  # [[x,y],sel]のような入力を2つ(リストとsel)受ける回路(mux)の変換関数
  def nbit_mux(inputs, gate_func), do: Enum.map(inputs, fn [[x,y], sel] -> gate_func.([x,y], sel)  end)

  def nand(inputs), do: nbit_converter(inputs, &RogicalGate.nand/2)
  def not_(inputs), do: nbit_not(inputs, &RogicalGate.not_/1)
  def or_(inputs), do: nbit_converter(inputs, &RogicalGate.or_/2)
  def and_(inputs), do: nbit_converter(inputs, &RogicalGate.and_/2)
  def xor_(inputs), do: nbit_converter(inputs, &RogicalGate.xor_/2)

  # ここに追加したよ~
  def mux(inputs), do: nbit_mux(inputs, &RogicalGate.mux/2)
  def dmux(inputs), do: nbit_converter(inputs, &RogicalGate.dmux/2)
end


# メインモジュール: ALUの動作をまとめたやつ
defmodule ALU do
  def lst_converter(x, y), do: Enum.map(Enum.zip(x, y), fn {a, b} -> [a, b] end)
  def lst_converter(x, y, sel), do: Enum.map(Enum.zip(x, y), fn {a, b} -> [[a, b], sel] end)
  def val_creater(val, len), do: Enum.map(1..len, fn _ -> val end)
  def compute(x, y, zx, nx, zy, ny, f, no) do
    nxout = common_calc_gate(x, zx, nx)
    nyout = common_calc_gate(y, zy, ny)

    merge_nx_ny = lst_converter(nxout, nyout)
    xandyout = NbitRogicalGate.and_(merge_nx_ny)
    xaddyout = NbitAdder.nbit_adder(merge_nx_ny)

    input_f = lst_converter(xandyout, xaddyout, f)
    fout = NbitRogicalGate.mux(input_f)
    not_fout = NbitRogicalGate.not_(fout)
    merge_fout = lst_converter(fout, not_fout, no)
    out = NbitRogicalGate.mux(merge_fout)
    ng = Enum.at(out, 0)
    zr = if Enum.member?(out, 1), do: 0, else: 1
    {out, zr, ng}
  end
  def common_calc_gate(lst, zero_key, not_key) do
    false_ = val_creater(0, length(lst))
    inputs = lst_converter(lst, false_, zero_key)
    mux_out = NbitRogicalGate.mux(inputs)
    not_out = NbitRogicalGate.not_(mux_out)

    inputs_out = lst_converter(mux_out, not_out, not_key)
    NbitRogicalGate.mux(inputs_out)
  end
end

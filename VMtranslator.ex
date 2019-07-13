defmodule Parser do
  @exist_arg2_command_types [:C_PUSH, :C_POP, :C_FUNCTION, :C_CALL]
  def read_file_and_adjustment(file) do
    File.read!(file)
    |> String.replace("\r", "")
    |> String.split("\n")
    |> Stream.map(&(String.trim(&1)))
    |> Stream.map(fn row -> String.split(row, "//") |> Enum.at(0) end)
    |> Stream.map(&(String.trim(&1)))
    |> Stream.filter(&(String.length(&1) > 0))
    |> Enum.to_list()
  end
  def command_type(asm_row_str) do
    splited_command = String.split(asm_row_str, " ")
    command_name = Enum.at(splited_command, 0)
    command_type = _command_type(command_name)
    {command_type, splited_command, command_name}
  end
  defp _command_type("push"), do: :C_PUSH
  defp _command_type("pop"), do: :C_POP
  defp _command_type("label"), do: :C_LABEL
  defp _command_type("goto"), do: :C_GOTO
  defp _command_type("if-goto"), do: :C_IF
  defp _command_type("function"), do: :C_FUNCTION
  defp _command_type("call"), do: :C_CALL
  defp _command_type("return"), do: :C_RETURN
  defp _command_type(_), do: :C_ARITHMETIC
  def arg1({:C_ARITHMETIC, sp_command, command_name}) do
    {:C_ARITHMETIC, sp_command, command_name, nil}
  end
  def arg1({:C_RETURN, sp_command, command_name}) do
    {:C_RETURN, sp_command, command_name, nil}
  end
  def arg1({command, sp_command, command_name}) do
    {command, sp_command, command_name, Enum.at(sp_command, 1)}
  end
  def arg2({command, sp_command, command_name, arg1}) do
    if command in @exist_arg2_command_types do
      {command, command_name, arg1, String.to_integer(Enum.at(sp_command, 2))}
    else
      {command, command_name, arg1, nil}
    end
  end
end

defmodule CodeWriter do
  @defined_symbol_relation %{
    "this" => "@THIS", "that" => "@THAT", "argument" => "@ARG",
    "local" => "@LCL", "pointer" => "@THIS"
  }
  def write_arithmetic({:C_ARITHMETIC, "add", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//add", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "M=M+D",
      "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "sub", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//sub", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "M=M-D",
      "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "neg", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//neg", "@SP", "M=M-1", "@SP", "A=M", "D=0", "M=D-M", "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "not", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//not", "@SP", "M=M-1", "@SP", "A=M", "M=!M", "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "or", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//or", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "M=M|D",
      "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "and", _arg1, _arg2, _label}) do
    res = Enum.join([
      "//and", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "M=M&D",
      "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "eq", _arg1, _arg2, label}) do
    res = Enum.join([
      "//eq", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "D=M-D", "@TRUE#{label}",
      "D;JEQ", "@SP", "A=M", "M=0", "@END#{label}", "0;JMP",
      "(TRUE#{label})", "@SP", "A=M", "M=-1", "(END#{label})", "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "gt", _arg1, _arg2, label}) do
    res = Enum.join([
      "//gt", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "D=M-D", "@TRUE#{label}",
      "D;JGT", "@SP", "A=M", "M=0", "@END#{label}", "0;JMP",
      "(TRUE#{label})", "@SP", "A=M", "M=-1", "(END#{label})", "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_ARITHMETIC, "lt", _arg1, _arg2, label}) do
    res = Enum.join([
      "//lt", "@SP", "M=M-1", "@SP", "A=M", "D=M", "@SP", "M=M-1", "@SP", "A=M", "D=M-D", "@TRUE#{label}",
      "D;JLT", "@SP", "A=M", "M=0", "@END#{label}", "0;JMP",
      "(TRUE#{label})", "@SP", "A=M", "M=-1", "(END#{label})", "@SP", "M=M+1", ""
    ], "\n")
    {:C_ARITHMETIC, res}
  end
  def write_arithmetic({:C_PUSH, "push", "constant", arg1, _}) do
    res = Enum.join(["//push constant", "@#{arg1}", "D=A", "@SP", "A=M", "M=D", "@SP", "M=M+1", ""], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_PUSH, "push", "static", arg1, file_name}) do
    res = Enum.join([
      "//push static", "@#{file_name}.#{arg1}", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_PUSH, "push", "temp", arg1, _label}) do
    res = Enum.join([
      "// push temp", "@R5", "D=A", "@#{arg1}", "A=D+A", "D=M", "@SP", "A=M", "M=D",
      "@SP", "M=M+1", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_PUSH, "push", "pointer", arg1, _}) do
    symbol = @defined_symbol_relation["pointer"]
    res = Enum.join([
      "//push pointer", symbol, "D=A", "@#{arg1}", "A=D+A", "D=M",
      "@SP", "A=M", "M=D", "@SP", "M=M+1", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_PUSH, "push", defined_symbol, arg1, _}) do
    symbol = @defined_symbol_relation[defined_symbol]
    res = Enum.join([
      "//push #{defined_symbol}", symbol, "D=M", "@#{arg1}", "A=D+A", "D=M",
      "@SP", "A=M", "M=D", "@SP", "M=M+1", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_POP, "pop", "static", arg1, file_name}) do
    res = Enum.join(["//push static", "@SP", "AM=M-1", "D=M", "@#{file_name}.#{arg1}", "M=D", ""], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_POP, "pop", "temp", arg1, _label}) do
    # val = if symbol == "pointer", do: "@#{label+3}", else: "@#{label+5}"
    res = Enum.join([
      "//pop temp", "@R5", "D=A", "@#{arg1}", "D=D+A", "@R13", "M=D", "@SP", "M=M-1",
      "@SP", "A=M", "D=M", "@R13", "A=M", "M=D", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_POP, "pop", "pointer", arg1, _}) do
    symbol = @defined_symbol_relation["pointer"]
    res = Enum.join([
      "//pop pointer", symbol, "D=A", "@#{arg1}", "D=D+A", "@R13", "M=D", "@SP", "M=M-1",
      "@SP", "A=M", "D=M", "@R13", "A=M", "M=D", ""
    ], "\n")
    {:C_PUSH, res}
  end
  def write_arithmetic({:C_POP, "pop", defined_symbol, arg1, _}) do
    symbol = @defined_symbol_relation[defined_symbol]
    res = Enum.join([
      "//pop #{defined_symbol}", symbol, "D=M", "@#{arg1}", "D=D+A", "@R13", "M=D", "@SP", "M=M-1",
      "@SP", "A=M", "D=M", "@R13", "A=M", "M=D", ""
    ], "\n")
    {:C_PUSH, res}
  end
end


defmodule VMtranslator do
  def main(path) do
    save_path = String.slice(path, 0..-3) <> "asm"
    file_name = String.split(path, "/") |> Enum.at(-1) |> String.slice(0..-4)
    save_string = Parser.read_file_and_adjustment(path)
      |> Stream.map(&(Parser.command_type(&1)))
      |> Stream.map(&(Parser.arg1(&1)))
      |> Stream.map(&(Parser.arg2(&1)))
      |> Enum.to_list()
      |> Enum.map_reduce(0, fn {command, arithmetic, arg1, arg2}, acc ->
          if arithmetic in ["eq", "gt", "lt"] do
            {CodeWriter.write_arithmetic({command, arithmetic, arg1, arg2, acc}), acc+1}
          else
            if arg1 == "static" do
              {CodeWriter.write_arithmetic({command, arithmetic, arg1, arg2, file_name}), acc}
            else
              {CodeWriter.write_arithmetic({command, arithmetic, arg1, arg2, acc}), acc}
            end
          end
        end)
      |> (fn {res, _} -> res end).()
      |> Enum.map(fn {_, converted} -> converted end)
      |> Enum.join("\n")
    File.write(save_path, save_string)
  end
end

path = "nand2tetris/projects/07/StackArithmetic/BasicTest/BasicTest.vm"
# path = "nand2tetris/projects/07/MemoryAccess/PointerTest/PointerTest.vm"
# path = "nand2tetris/projects/07/MemoryAccess/StaticTest/StaticTest.vm"
IO.inspect(VMtranslator.main(path))

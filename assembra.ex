defmodule Parser do
  @defined_symbols %{
    "@SP" => "@0", "@LCL" => "@1", "@ARG" => "@2",
    "@THIS" => "@3", "@THAT" => "@4", "@R0" => "@0",
    "@R1" => "@1", "@R2" => "@2", "@R3" => "@3",
    "@R4" => "@4", "@R5" => "@5", "@R6" => "@6",
    "@R7" => "@7", "@R8" => "@8", "@R9" => "@9",
    "@R10" => "@10", "@R11" => "@11", "@R12" => "@12",
    "@R13" => "@13", "@R14" => "@14", "@R15" => "@15",
    "@SCREEN" => "@16384", "@KBD" => "@24576"
  }
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
    case String.starts_with?(asm_row_str, "@") do
      true -> _command_type(asm_row_str)
      false ->
        if String.starts_with?(asm_row_str, "(") do
          {:L_COMMAND, asm_row_str}
        else
          {:C_COMMAND, asm_row_str}
        end
    end
  end

  defp _command_type(asm_row_str) do
    val = @defined_symbols[asm_row_str]
    if val do
      {:A_COMMAND, val}
    else
      is_integer? = String.slice(asm_row_str, 1..-1) |> Integer.parse()
      if is_integer? != :error do
        {:A_COMMAND, asm_row_str}
      else
        {:L_COMMAND, asm_row_str}
      end
    end
  end

  def symbol_or_mnemonic({:C_COMMAND, asm_row_str}) do
    dest = if String.contains?(asm_row_str, "="), do: until_slice(asm_row_str, "="), else: false
    jump_b = if String.contains?(asm_row_str, ";"), do: until_slice(asm_row_str, ";"), else: false
    jump = if jump_b, do: String.replace(asm_row_str, jump_b <> ";", ""), else: false
    comp = extraction_comp(dest, jump, asm_row_str)
    {dest, comp, jump}
  end
  def symbol_or_mnemonic({_, asm_row_str}) do
    String.slice(asm_row_str, 1..-1)
  end

  defp extraction_comp(false, false, _), do: false
  defp extraction_comp(dest, false, asm_row_str), do: String.replace(asm_row_str, dest <> "=", "")
  defp extraction_comp(false, jump, asm_row_str), do: String.replace(asm_row_str, ";" <> jump, "")
  defp extraction_comp(dest, jump, asm_row_str) do
    asm_row_str
    |> String.replace(dest <> "=", "")
    |> String.replace(";" <> jump, "")
  end

  def until_slice(str, target) do
    str_lst = String.codepoints(str)
    target_index = Enum.find_index(str_lst, &(&1 == target))
    case target_index do
      nil -> str
      0 -> Enum.slice(str_lst, 0..target_index) |> Enum.join()
      _ -> Enum.slice(str_lst, 0..target_index-1) |> Enum.join()
    end
  end
end

defmodule BinaryCode do
  @dest_relation %{
    false => "000", "M" => "001", "D" => "010",
    "MD" => "011", "A" => "100", "AM" => "101",
    "AD" => "110", "AMD" => "111"
  }
  @jump_relation %{
    false => "000", "JGT" => "001", "JEQ" => "010",
    "JGE" => "011", "JLT" => "100", "JNE" => "101",
    "JLE" => "110", "JMP" => "111"
  }
  @comp_relation %{
    "0" => "101010", "1" => "111111", "-1" => "111010",
    "D" => "001100", "A" => "110000", "!D" => "001101",
    "!A" => "110001", "-D" => "001111", "-A" => "110011",
    "D+1" => "011111", "A+1" => "110111", "D-1" => "001110",
    "A-1" => "110010", "D+A" => "000010", "D-A" => "010011",
    "A-D" => "000111", "D&A" => "000000", "D|A" => "010101",
    "M" => "110000", "!M" => "110001", "-M" => "110011",
    "M+1" => "110111", "M-1" => "110010", "D+M" => "000010",
    "D-M" => "010011", "M-D" => "000111", "D&M" => "000000",
    "D|M" => "010101"
  }
  @comp_mnemonic_a_1 ["M", "!M", "-M", "M+1", "M-1", "D+M", "D-M", "M-D", "D&M", "D|M"]
  def dest_to_binary(mnemonic), do: Map.get(@dest_relation, mnemonic)
  def comp_to_binary(mnemonic), do: Map.get(@comp_relation, mnemonic)
  def jump_to_binary(mnemonic), do: Map.get(@jump_relation, mnemonic)
  def comp_a_num(mnemonic), do: if Enum.member?(@comp_mnemonic_a_1, mnemonic), do: "1", else: "0"
  def to_binary_calc("0"), do: "0"
  def to_binary_calc(num_str), do: _to_binary_calc(String.to_integer(num_str), [])
  defp _to_binary_calc(1, acc), do: "1" <> Enum.join(acc)
  defp _to_binary_calc(num, acc), do: _to_binary_calc(div(num, 2), [rem(num, 2)] ++ acc)
  def add_0bit(base, bit_num) do
    add_num = bit_num - String.length(base)
    Enum.reduce(1..add_num, "", fn _, acc -> acc <> "0" end) <> base
  end
end

defmodule SymbolTable do
  def create_init_symbol_table(), do: Map.new()
  def add_entry(map, symbol, address), do: Map.put(map, symbol, address)
  def contains(map, symbol), do: Map.has_key?(map, symbol)
  def get_address(map, symbol), do: map[symbol]
  def get_symbol(map, address, no_exist \\ :no_exist) do
    map
    |> Map.keys()
    |> Enum.reduce(no_exist, fn key, acc ->
      if map[key] == address, do: key, else: acc
    end)
  end
end

defmodule Assembra do
  def to_binary(path, save_path) do
    res = Parser.read_file_and_adjustment(path)
          |> code_convert_to_command()
    [symbol_table, _, _] = create_symbol_table(res)
    replace_from_symbol_table(res, symbol_table)
    |> Enum.map(&(Parser.symbol_or_mnemonic(&1)))
    |> code_to_binary()
    |> save_to_hack_file(save_path)
  end
  def code_convert_to_command(read_asm_file) do
    Enum.map(read_asm_file, &(Parser.command_type(&1)))
  end
  defp search_code_index_num(commands, symbol) do
    target_str = String.replace(symbol, "@", "(") <> ")"
    Enum.reduce(commands, [0, 0], fn command, [counter, index] ->
      if command == target_str do
        [counter+1, counter]
      else
        if String.starts_with?(command, "(") do
          [counter, index]
        else
          [counter+1, index]
        end
      end
    end)
  end
  defp search_code_index_num_variable(commands, symbol) do
    Enum.reduce(commands, [], fn row, acc ->
      if row != symbol do
        if String.starts_with?(row, "@") do
          if row in acc do
            acc
          else
            acc ++ [row]
          end
        else
          acc ++ [row]
        end
      else
        acc ++ [row]
      end
     end)
    |> Enum.reduce([0, 0, 0], fn command, [index_at, counter, last] ->
      if command == symbol do
        [index_at+1, counter+1, index_at]
      else
        [index_at+1, counter, last]
      end
     end)
  end
  def create_symbol_table(parse_command) do
    commands = Enum.map(parse_command, fn {_, v} -> v end)
    Enum.reduce(parse_command, [SymbolTable.create_init_symbol_table(), 0, 1024], fn {command, symbol}, [symbol_table, counter, memory_index] ->
      if command == :L_COMMAND do
        if SymbolTable.contains(symbol_table, symbol) do
          [symbol_table, counter+1, memory_index]
        else
          if String.starts_with?(symbol, "(") do
            [SymbolTable.add_entry(symbol_table, symbol, counter), counter+1, memory_index]
          else
            if String.replace(symbol, "@", "(") <> ")" in commands do
              [_, index_num] = search_code_index_num(commands, symbol)
              [SymbolTable.add_entry(symbol_table, symbol, index_num), counter+1, memory_index]
            else
              # ここにifが必要??
              IO.puts(symbol)
              [a, b, index_num] = search_code_index_num_variable(commands, symbol)
              IO.inspect([a,b,index_num])
              [SymbolTable.add_entry(symbol_table, symbol, index_num-1), counter+1, memory_index+1]
            end
          end
        end
      else
        [symbol_table, counter+1, memory_index]
      end
    end)
  end
  def replace_from_symbol_table(res, symbol_table) do
    Enum.filter(res, fn {command, nm} ->
      if String.first(nm) != "(" and String.last(nm) != ")" do
        {command, nm}
      end
    end)
    |> Enum.map(fn {command, nm} ->
        address_num = symbol_table[nm]
        if address_num do
          {command, "@" <> Integer.to_string(address_num)}
        else
          {command, nm}
        end
      end)
  end
  def code_to_binary(replace_res) do
    Enum.map(replace_res, fn row ->
      if is_tuple(row) do
        {dest, comp, jump} = row
        a_b = BinaryCode.comp_a_num(comp)
        dest_b = BinaryCode.dest_to_binary(dest)
        comp_b = BinaryCode.comp_to_binary(comp)
        jump_b = BinaryCode.jump_to_binary(jump)
        "111" <> Enum.join([a_b, comp_b, dest_b, jump_b])
      else
        BinaryCode.to_binary_calc(row)
        |> BinaryCode.add_0bit(16)
      end
    end)
  end
  def save_to_hack_file(binary_str_lst, save_path) do
    File.write(save_path, Enum.join(binary_str_lst, "\n"))
  end
end

path = "nand2tetris/projects/06/pong/PongL.asm"
save_path = "nand2tetris/projects/06/pongL.hack"
res = Assembra.to_binary(path, save_path)
IO.inspect(res)

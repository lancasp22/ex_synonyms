defmodule ExSynonyms do

  def merge() do
    {:ok, synonyms} = File.open("c:/temp/firstnames.csv")
    {:ok, new_synonyms} = File.open("c:/temp/new_synonyms.txt")
    {:ok, output_file} = File.open("c:/temp/output_synonyms.txt", [:write])

    new_syn_list = process_new_synonym(new_synonyms, [], :bof)
    process_synonym(synonyms, output_file, new_syn_list, :bof)
  end

  defp process_synonym(synonyms, output_file, new_syn_list, :bof) do
    line = IO.read(synonyms, :line)
    process_synonym(synonyms, output_file, new_syn_list, line) 
  end

  defp process_synonym(synonyms, output_file, new_syn_list, :eof) do
    File.close(synonyms) 
    File.close(output_file)
  end

  defp process_synonym(synonyms, outfile, new_syn_list, line) do

    [source,targets] = String.split(line, "=>")
    targets = String.split(targets, ",")
    targets = Enum.map(targets, fn(target) -> standardise_name(target) end)

    new_synonym = Enum.find(new_syn_list, fn(%{source: new_source}) -> new_source == source end)

    if new_synonym == nil do
      IO.write(outfile, line)
    else
      new_targets = new_synonym[:targets]
      targets = (targets -- new_targets) ++ new_targets
      targets = Enum.sort(targets, fn(target1, target2) -> target1 < target2 end)
      {_, line} = Enum.map_reduce(targets, source <> "=>", fn(target, acc) -> {target, acc <> target <> ","} end)
      line = String.trim_trailing(line, ",")
      IO.puts(outfile, line)
    end
    
    # Here write the outfile

    line = IO.read(synonyms, :line)
    process_synonym(synonyms, outfile, new_syn_list, line)    
  end



  defp process_new_synonym(synonyms, syn_list, :eof) do
    File.close(synonyms) 
    syn_list
  end

  defp process_new_synonym(synonyms, syn_list, :bof) do
    line = IO.read(synonyms, :line)
    process_new_synonym(synonyms, syn_list, line) 
  end

  defp process_new_synonym(synonyms, syn_list, line) do

    [source,targets] = String.split(line, "=>")
    source = standardise_name(source)
    targets = String.split(targets, ",")
    targets = Enum.map(targets, fn(target) -> standardise_name(target) end)

    # syn_list = List.insert_at(syn_array, -1, %{source: source, targets: targets})
    syn_list = syn_list ++ [%{source: source, targets: targets}]

    line = IO.read(synonyms, :line)
    process_new_synonym(synonyms, syn_list, line)    
  end


  defp standardise_name(name) do
    String.trim(name)
    |> String.downcase()
  end
end

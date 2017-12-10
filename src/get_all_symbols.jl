function get_all_symbols(cur_package::Module)
  all_symbols = []

  for cur_name in names(cur_package, true)
    Base.isidentifier(cur_name) || continue
    in(cur_name, (Symbol(cur_package), :eval)) && continue

    push!(all_symbols, cur_name)
  end

  all_symbols
end

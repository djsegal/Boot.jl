function get_package_methods(cur_package::Module)
  all_symbols = get_all_symbols(cur_package)

  cur_methods_list = map(
    cur_var -> try methods(getfield(cur_package, cur_var)) ; catch [] ; end,
    all_symbols
  )

  filter!(
    cur_list -> !isempty(cur_list),
    cur_methods_list
  )

  cur_methods_list = map(
    cur_methods -> filter(
      cur_method -> cur_method.module == cur_package,
      cur_methods.ms
    ),
    cur_methods_list
  )

  flatten_array(cur_methods_list)
end

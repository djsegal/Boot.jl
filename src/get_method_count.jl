function get_method_count(cur_package::Module)

  method_count = 0

  for cur_name in cur_package.names(cur_package, true)

    isdefined(cur_package, cur_name) || continue

    cur_obj = getfield(cur_package, cur_name)

    isa(cur_obj, Base.Callable) || continue

    method_count += length(methods(cur_obj))

  end

  method_count

end

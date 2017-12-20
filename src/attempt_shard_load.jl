function attempt_shard_load!(cur_package::Module, cur_dict::Dict, cur_shard::Expr)

  cur_error = nothing

  cur_time = @elapsed(
    try
      cur_package.eval(cur_shard)
    catch tmp_error
      cur_error = tmp_error
    end
  )

  ( cur_error == nothing ) &&
    ( return cur_error, cur_time )

  isa(cur_error, UndefVarError) ||
    load_invalid_file(cur_package, cur_dict)

  cur_dict["time"] = cur_time

  cur_dict["undef"] = cur_error.var

  return cur_error, cur_time

end

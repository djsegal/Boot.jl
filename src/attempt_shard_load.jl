const allowed_errors = [
  UndefVarError,
  ArgumentError
]

function attempt_shard_load!(cur_package::Module, cur_dict::Dict, cur_shard::Expr)

  is_include_call = (
    cur_shard.head == :call &&
    first(cur_shard.args) == :include
  )

  is_include_call && return

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

  is_valid_file = any(
    a_error -> isa(cur_error, a_error),
    allowed_errors
  )

  cur_dict["time"] = cur_time
  is_valid_file || load_invalid_file(cur_package, cur_dict)

  cur_dict["undef"] = cur_error.var

  return cur_error, cur_time

end

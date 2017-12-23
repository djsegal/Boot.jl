const allowed_errors = [
  UndefVarError,
  ArgumentError
]

function attempt_shard_load!(cur_package::Module, cur_info::FileInfo, cur_shard::Expr, is_test::Bool=false)

  is_include_call = (
    !is_test &&
    cur_shard.head == :call &&
    first(cur_shard.args) == :include
  )

  is_include_call && return true

  if cur_shard.head == :module
    check_module_node!(cur_package, cur_info, cur_shard) || return false
  end

  cur_error = nothing

  cur_func_name = _get_function_name(cur_shard)

  methods_list = ( cur_func_name != nothing && isdefined(cur_package, cur_func_name) ) ?
    methods(getfield(cur_package, cur_func_name)) : []

  cur_symbol_count = get_method_count(cur_package)

  cur_time = @elapsed(
    try
      cur_package.eval(cur_shard)
    catch tmp_error
      cur_error = tmp_error
    end
  )

  if cur_error == nothing
    cur_symbol_count -= get_method_count(cur_package)

    cur_symbol_count *= -1

    iszero(cur_symbol_count) && return true

    setfield!(cur_shard, :head, :tuple)
    empty!(cur_shard.args)

    return true
  end

  while isa(cur_error, LoadError)
    cur_error = cur_error.error
  end

  is_valid_file = any(
    a_error -> isa(cur_error, a_error),
    allowed_errors
  )

  is_valid_file || load_invalid_file(cur_package, cur_info)

  methods_list = ( cur_func_name != nothing && isdefined(cur_package, cur_func_name) ) ?
    setdiff( methods(getfield(cur_package, cur_func_name)), methods_list) : []

  isempty(methods_list) || purge_corrupted_methods!(cur_package, methods_list)

  cur_info.time = cur_time

  cur_info.undef = nothing

  isa(cur_error, ArgumentError) &&
    ( cur_dict["time"] *= 10 )

  isa(cur_error, UndefVarError) &&
    ( cur_dict["undef"] = cur_error.var )

  return false

end

function _get_function_name(cur_shard::Expr)
  cur_func_name = nothing

  if cur_shard.head == :macrocall && string(cur_shard.args[1]) == "Core.@doc"
    cur_shard = cur_shard.args[3]
  end

  if cur_shard.head == :function

    cur_func_name = cur_shard.args[1].args[1]

    if isa(cur_func_name, Expr)

      if cur_func_name.head == :(.)
        cur_func_name = nothing
      else
        cur_func_name = cur_func_name.args[1]
      end

    end

    isa(cur_func_name, Expr) && ( cur_func_name = nothing )

  end

  cur_func_name
end

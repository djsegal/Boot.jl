function check_module_node!(cur_package::Module, cur_dict::Dict, cur_shard::Expr)

  cur_undef = _check_for_bad_imports(cur_package::Module, cur_shard::Expr)

  if cur_undef == nothing
    cur_undef = _check_for_bad_types(cur_package::Module, cur_shard::Expr)
  end

  ( cur_undef == nothing ) && return true

  cur_dict["time"] = 100.0 # set to a long time

  cur_dict["undef"] = cur_undef

  return false

end

function _check_for_bad_imports(cur_package::Module, cur_shard::Expr)
  import_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && cur_arg.head == :import,
    cur_shard.args[3].args
  )

  cur_import_exprs = filter(
    cur_arg -> isdefined(cur_arg, :head) && cur_arg.head == :toplevel,
    cur_shard.args[3].args
  )

  for cur_expr in cur_import_exprs
    for cur_sub_expr in cur_expr.args
      ( cur_sub_expr.head == :import ) &&
        push!(import_list, cur_sub_expr)
    end
  end

  for cur_import in import_list
    ( cur_import.args[1] == Symbol(cur_package) ) || continue

    work_module = cur_package

    for cur_sub_sub_expr in cur_import.args[2:end-1]
      work_module = getfield(work_module, cur_sub_sub_expr)
    end

    work_method = cur_import.args[end]

    isdefined(work_module, work_method) && continue

    return work_method
  end

  return
end

function _check_for_bad_types(cur_package::Module, cur_shard::Expr)
  type_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && cur_arg.head == :type,
    cur_shard.args[3].args
  )

  for cur_type in type_list
    for cur_field in cur_type.args[3].args
      ( cur_field.head == :line ) && continue
      ( cur_field.head == :(=) ) && continue

      ( cur_field.head == :(::) ) ||
        error("Invalid type definition for loading")

      ( length(cur_field.args) == 2 ) ||
        error("Invalid field definition for loading")

      cur_undef = _check_type_field(cur_package, cur_field.args[2])

      ( cur_undef == nothing ) || return cur_undef
    end
  end

  return
end

function _check_type_field(cur_package::Module, cur_shard::Expr)
  ( cur_shard.head == :(.) ) &&
    return _check_dot_field(cur_package::Module, cur_shard)

  for cur_sub_shard in cur_shard.args
    undef_type = _check_type_field(cur_package, cur_sub_shard)
    ( undef_type == nothing ) || return undef_type
  end

  return
end

function _check_dot_field(cur_package::Module, cur_shard::Expr)
  cur_error = nothing
  try
    cur_package.eval(cur_shard)
  catch tmp_error
    cur_error = tmp_error
  end
  ( cur_error == nothing ) && return

  isa(cur_error, UndefVarError) || rethrow(cur_error)
  return cur_error.var
end

function _check_type_field(cur_package::Module, cur_shard::Symbol)
  isdefined(cur_package, cur_shard) && return

  cur_shard
end

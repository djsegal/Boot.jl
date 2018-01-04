function check_module_node!(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)

  cur_undef = _check_for_bad_imports(cur_package, cur_info, cur_shard)

  if cur_undef == nothing
    cur_undef = _check_for_bad_types(cur_package, cur_info, cur_shard)
  end

  if cur_undef == nothing
    cur_undef = _check_for_bad_methods(cur_package, cur_info, cur_shard)
  end

  if cur_undef == nothing
    has_unloaded_file = false

    cur_folder = dirname(cur_info.name)

    for cur_sub_shard in cur_shard.args[3].args
      ( cur_sub_shard.head == :call ) || continue
      ( first(cur_sub_shard.args) == :include ) || continue

      full_include_path = joinpath(cur_folder, cur_sub_shard.args[2])

      if in(full_include_path, map(tmp_info -> tmp_info.name, cur_info.parent.file_infos))
        has_unloaded_file = true
        break
      end

      cur_sub_shard.args[2] = full_include_path
    end

    has_unloaded_file || return true
  end

  # put modules in the middle of the pack

  if iszero(length(cur_info.parent.file_infos))
    cur_info.time = 0.0
  else
    cur_info.time = median(map(tmp_info -> tmp_info.time, cur_info.parent.file_infos))
  end

  cur_info.undef = cur_undef

  return false

end

function _check_for_bad_methods(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
  method_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && (
      cur_arg.head == :function ||
      ( cur_arg.head == :(=) && cur_arg.args[1].head == :call )
    ),
    cur_shard.args[3].args
  )

  method_list = map(cur_method -> first(cur_method.args), method_list)

  isempty(method_list) && return

  for cur_method in method_list
    ( cur_method.head == :call ) ||
      error("Unable to determine what to do with non-call function shard")

    cur_call = first(cur_method.args)
    cur_args = cur_method.args[2:end]

    excused_vars = Symbol[]

    if isa(cur_call, Expr)
      ( cur_call.head == :curly ) ||
        error("Unable to check type with non-curly head type of: $(cur_call.head) [3/4]")

      append!(excused_vars, cur_call.args[2:end])
    end

    for cur_arg in cur_args
      isa(cur_arg, Expr) || continue
      cur_arg.head == :(::) || continue

      cur_type_association = cur_arg.args[2]

      deep_isdefined(cur_package, cur_info, cur_type_association, excused_vars) ||
        return cur_type_association
    end
  end

  return
end

function _check_for_bad_imports(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
  import_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && ( cur_arg.head == :import || cur_arg.head == :using ),
    cur_shard.args[3].args
  )

  cur_import_exprs = filter(
    cur_arg -> isdefined(cur_arg, :head) && cur_arg.head == :toplevel,
    cur_shard.args[3].args
  )

  for cur_expr in cur_import_exprs
    for cur_sub_expr in cur_expr.args
      ( cur_sub_expr.head == :import || cur_sub_expr.head == :using ) &&
        push!(import_list, cur_sub_expr)
    end
  end

  for cur_import in import_list

    dot_count = 0
    for cur_arg in cur_import.args
      ( cur_arg == :(.) ) || break
      dot_count += 1
    end

    if !iszero(dot_count)
      ( dot_count == 2 ) ||
        error("Invalid module import")

      shift!(cur_import.args)
      cur_import.args[1] = Symbol(cur_package)
    end

    # if cur_import.args[1] != Symbol(cur_package)
    #   println("scumbag")
    #   println(Symbol(cur_info.parent.boot_module))
    #   println(cur_import.args[1])
    #   println(404)
    #   cur_boot_module = getfield(cur_package, Symbol(cur_info.parent.boot_module))
    #   try
    #     cur_boot_module.eval(cur_import)
    #   catch
    #     Base.invokelatest(
    #       cur_boot_module.eval,
    #       cur_import
    #     )
    #   end

    #   continue
    # end

    work_method = cur_import.args[end]

    work_module = nothing
    bad_expression = nothing

    tmp_modules = [ cur_package , cur_info.parent.boot_module , cur_package ]

    for tmp_module in tmp_modules
      work_module = tmp_module

      for cur_sub_sub_expr in cur_import.args[2+(dot_count-1):end-1]
        if !isdefined(work_module, cur_sub_sub_expr)
          bad_expression = cur_sub_sub_expr
          work_module = nothing
          break
        end

        work_module = getfield(work_module, cur_sub_sub_expr)
      end

      ( work_module == nothing ) && continue

      isdefined(work_module, work_method) && break
    end

    ( work_module == nothing ) && return bad_expression

    isdefined(work_module, work_method) && continue

    return work_method
  end

  return
end

function _check_for_bad_types(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
  type_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && cur_arg.head == :type,
    cur_shard.args[3].args
  )

  excused_vars = Array{Symbol}(0)

  for cur_type in type_list
    cur_type_definition = cur_type.args[2]

    if isa(cur_type_definition, Expr)
      if cur_type_definition.head == :(<:)
        ( length(cur_type_definition.args) == 2 ) ||
          error("Currently invalid type shard in module load [1/2]")

        cur_type_association = cur_type_definition.args[2]

        deep_isdefined(cur_package, cur_info, cur_type_association) ||
          return cur_type_association
      else
        ( cur_type_definition.head == :curly ) ||
          error("Unable to check type with non-curly head type of: $(cur_type_definition.head) [2/4]")

        for cur_sub_shard in cur_type_definition.args[2:end]
          ( cur_sub_shard.head == :(<:) ) ||
            error("Unable to check type with a sub-head type of: $(cur_type_definition.head)")

          ( length(cur_sub_shard.args) == 2 ) ||
            error("Currently invalid type shard in module load [2/2]")

          cur_param_type, cur_type_association = cur_sub_shard.args

          push!(excused_vars, cur_param_type)

          deep_isdefined(cur_package, cur_info, cur_type_association) ||
            return cur_type_association
        end
      end
    end

    for cur_field in cur_type.args[3].args
      ( cur_field.head == :function ) && continue
      ( cur_field.head == :line ) && continue
      ( cur_field.head == :(=) ) && continue

      ( cur_field.head == :(::) ) ||
        error("Invalid type definition for loading")

      ( length(cur_field.args) == 2 ) ||
        error("Invalid field definition for loading")

      cur_undef = _check_type_field(cur_package, cur_info, cur_field.args[2], excused_vars)

      ( cur_undef == nothing ) || return cur_undef
    end
  end

  return
end

function _check_type_field(cur_package::Module, cur_info::FileInfo, cur_shard::Expr, excused_vars::Array{Symbol})
  ( cur_shard.head == :(.) ) &&
    return _check_dot_field(cur_package, cur_info, cur_shard)

  for cur_sub_shard in cur_shard.args
    undef_type = _check_type_field(cur_package, cur_info, cur_sub_shard, excused_vars)
    ( undef_type == nothing ) || return undef_type
  end

  return
end

function _check_type_field(cur_package::Module, cur_info::FileInfo, cur_shard::Symbol, excused_vars::Array{Symbol})
  in(cur_shard, excused_vars) && return

  deep_isdefined(cur_package, cur_info, cur_shard) && return

  cur_shard
end

function _check_dot_field(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
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

function deep_isdefined(cur_package::Module, cur_info::FileInfo, cur_shard::Expr, excused_vars::Vector{Symbol}=Symbol[])
  ( cur_shard.head == :curly ) ||
    error("Unable to check type with non-curly head type of: $(cur_type_definition.head) [1/4]")

  for cur_sub_shard in cur_shard.args
    isa(cur_sub_shard, Symbol) || continue

    deep_isdefined(cur_package, cur_info, cur_sub_shard, excused_vars) ||
      return false
  end

  return true
end

function deep_isdefined(cur_package::Module, cur_info::FileInfo, cur_shard::Symbol, excused_vars::Vector{Symbol}=Symbol[])
  tmp_packages = [ cur_package , cur_info.parent.boot_module ]

  in(cur_shard, excused_vars) && return true

  for tmp_package in tmp_packages
    isdefined(tmp_package, cur_shard) && return true
  end

  return false
end

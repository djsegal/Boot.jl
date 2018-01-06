function check_module_node!(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
  cur_shard = _clean_module_shard!(cur_package, deepcopy(cur_shard))

  cur_undef = _check_for_bad_imports(cur_package, cur_info, cur_shard)
  println(123)
  println(cur_undef)

  if cur_undef == nothing
    cur_undef = _check_for_bad_types(cur_package, cur_info, cur_shard)
  end
  println(1234)
  println(cur_undef)

  if cur_undef == nothing
    cur_undef = _check_for_bad_methods(cur_package, cur_info, cur_shard)
  end
  println(1235)
  println(cur_undef)

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
      ( cur_arg.head == :(=) && isdefined(cur_arg.args[1], :head) && cur_arg.args[1].head == :call )
    ),
    cur_shard.args[3].args
  )

  method_list = map(cur_method -> first(cur_method.args), method_list)

  isempty(method_list) && return

  base_excused_vars = Symbol[]

  type_list = filter(
    cur_arg -> isdefined(cur_arg, :head) && ( cur_arg.head == :type || cur_arg.head == :abstract ),
    cur_shard.args[3].args
  )

  for cur_type in type_list

    cur_type_symbol = nothing

    ( cur_type.head == :abstract ) &&
      ( cur_type_symbol = cur_type.args[1] )

    ( cur_type.head == :type ) &&
      ( cur_type_symbol = cur_type.args[2] )

    ( cur_type_symbol == nothing ) &&
      error("Unable to determine what to do with cur_type: $cur_type")

    if isa(cur_type_symbol, Expr) && cur_type_symbol.head == :curly
      println("rookie")
      main_shard, cur_type_symbol = cur_type_symbol.args
      push!(base_excused_vars, main_shard)
    end

    if isa(cur_type_symbol, Expr) && cur_type_symbol.head == :(<:)
      println("sup")
      cur_type_symbol = first(cur_type_symbol.args)
    end

    isa(cur_type_symbol, Symbol) ||
      error("Unable to determine what to do with cur_type: $cur_type_symbol")

    push!(base_excused_vars, cur_type_symbol)
  end

  for cur_method in method_list
    ( cur_method.head == :call || cur_method.head == :where ) ||
      error("Unable to determine what to do with non-call function shard: $(cur_method.head)")

    cur_excused_vars = deepcopy(base_excused_vars)

    if cur_method.head == :where
      ( length(cur_method.args) == 2 ) ||
        error("Currently invalid type shard in module load [3/4]")

      cur_method, cur_type_definition = cur_method.args

      ( cur_type_definition.head == :(<:) ) ||
        error("Invalid where clause in module load")

      ( length(cur_type_definition.args) == 2 ) ||
        error("Currently invalid type shard in module load [4/4]")

      cur_param_type, cur_type_association = cur_type_definition.args

      deep_isdefined(cur_package, cur_info, cur_type_association, cur_excused_vars) ||
        return cur_type_association

      push!(cur_excused_vars, cur_param_type)
    end

    cur_call = first(cur_method.args)
    cur_args = cur_method.args[2:end]

    if isa(cur_call, Expr) && cur_call.head != :(.)
      ( cur_call.head == :curly ) ||
        error("Unable to check type with non-curly head type of: $(cur_call.head) [3/4]")

      new_excused_vars = cur_call.args[2:end]

      for (cur_index, cur_sub_shard) in enumerate(new_excused_vars)
        isa(cur_sub_shard, Expr) || continue

        cur_param_type, cur_type_association = cur_sub_shard.args

        deep_isdefined(cur_package, cur_info, cur_type_association, cur_excused_vars) ||
          return cur_type_association

        new_excused_vars[cur_index] = cur_param_type
      end

      append!(cur_excused_vars, new_excused_vars)
    end

    for cur_arg in cur_args
      isa(cur_arg, Expr) || continue
      cur_arg.head == :(::) || continue

      ( length(cur_arg.args) < 3 ) || error("Invalid :(::) args size in module call")

      cur_type_association = last(cur_arg.args)

      deep_isdefined(cur_package, cur_info, cur_type_association, cur_excused_vars) ||
        return cur_type_association
    end
  end

  return
end

function _get_import_list(cur_shard::Expr)
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

  import_list
end

function _check_for_bad_imports(cur_package::Module, cur_info::FileInfo, cur_shard::Expr)
  import_list = _get_import_list(cur_shard)

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

    if cur_import.args[1] != Symbol(cur_package)
      isdefined(cur_package, last(cur_import.args)) && continue

      cur_info.parent.boot_module.include_string(string(cur_import))

      continue
    end

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
    cur_arg -> isdefined(cur_arg, :head) && ( cur_arg.head == :type || cur_arg.head == :abstract ),
    cur_shard.args[3].args
  )

  excused_vars = Symbol[]

  for cur_type in type_list
    println("asdf ", cur_type)
    cur_type_definition = nothing

    if cur_type.head == :abstract
      cur_type_definition = cur_type.args[1]
      push!(excused_vars, cur_type_definition)
      continue
    end

    cur_type_definition = cur_type.args[2]

    if isa(cur_type_definition, Symbol)
      push!(excused_vars, cur_type_definition)
    end

    if isa(cur_type_definition, Expr)
      if cur_type_definition.head == :(<:)
        ( length(cur_type_definition.args) == 2 ) ||
          error("Currently invalid type shard in module load [1/4]")

        cur_param_type, cur_type_association = cur_type_definition.args

        if isa(cur_param_type, Symbol)
          push!(excused_vars, cur_param_type)
        elseif cur_param_type.head == :curly
          cur_type_definition = cur_param_type
        else
          error("Unable to determine what to do with param type of: $(cur_param_type.head)")
        end

        deep_isdefined(cur_package, cur_info, cur_type_association, excused_vars) ||
          ( println("axd") ; return cur_type_association )
      end

      if cur_type_definition.head != :(<:)
        ( cur_type_definition.head == :curly ) ||
          error("Unable to check type with non-curly head type of: $(cur_type_definition.head) [2/4]")

        for cur_sub_shard in cur_type_definition.args[2:end]
          if isa(cur_sub_shard, Symbol)
            push!(excused_vars, cur_sub_shard)
            continue
          end

          ( cur_sub_shard.head == :(<:) ) ||
            error("Unable to check type with a sub-head type of: $(cur_type_definition.head)")

          ( length(cur_sub_shard.args) == 2 ) ||
            error("Currently invalid type shard in module load [2/4]")

          cur_param_type, cur_type_association = cur_sub_shard.args

          push!(excused_vars, cur_param_type)

          deep_isdefined(cur_package, cur_info, cur_type_association, excused_vars) ||
            ( println("nimubs") ; return cur_type_association )
        end
      end
    end

    for cur_field in cur_type.args[3].args
      isa(cur_field, Symbol) && continue

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

  deep_isdefined(cur_package, cur_info, cur_shard, excused_vars) && return

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

function deep_isdefined(cur_package::Module, cur_info::FileInfo, cur_shard::Expr, excused_vars::Vector{Symbol})
  if cur_shard.head == :(.)
    cur_dot_reference = _expand_dot_var(cur_package, cur_shard)

    tmp_packages = [ cur_package , cur_info.parent.boot_module ]

    cur_field = nothing

    first_reference = first(cur_dot_reference)

    for tmp_package in tmp_packages
      isdefined(tmp_package, first_reference) || continue
      cur_field = getfield(tmp_package, first_reference)
      break
    end

    ( cur_field == nothing ) && return false

    for cur_reference in cur_dot_reference[2:end]
      isdefined(cur_field, cur_reference) || return false
      cur_field = getfield(cur_field, cur_reference)
    end

    return true
  end

  ( cur_shard.head == :curly ) ||
    error("Unable to check type with non-curly head type of: $(cur_shard.head) [1/4]")

  for cur_sub_shard in cur_shard.args
    isa(cur_sub_shard, Symbol) || continue

    deep_isdefined(cur_package, cur_info, cur_sub_shard, excused_vars) ||
      return false
  end

  return true
end

function deep_isdefined(cur_package::Module, cur_info::FileInfo, cur_shard::Symbol, excused_vars::Vector{Symbol})
  tmp_packages = [ cur_package , cur_info.parent.boot_module ]

  in(cur_shard, excused_vars) && return true

  for tmp_package in tmp_packages
    isdefined(tmp_package, cur_shard) && return true
  end

  return false
end

_clean_module_shard!(cur_package::Module, cur_shard::Any) = cur_shard

function _clean_module_shard!(cur_package::Module, cur_shard::Expr)
  if cur_shard.head == :macrocall && string(cur_shard.args[1]) == "Core.@doc"
    cur_shard = cur_shard.args[3]
    isa(cur_shard, Symbol) && return cur_shard
  end

  expanded_shard = cur_package.macroexpand(cur_shard)

  if expanded_shard.head != :error
    cur_shard = expanded_shard
  end

  for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
    cur_shard.args[cur_index] = _clean_module_shard!(cur_package, cur_sub_shard)
  end

  cur_shard
end

function _expand_dot_var(cur_package::Module, cur_shard::Expr, cur_list::Vector{Symbol}=Symbol[])
  ( length(cur_shard.args) == 2 ) ||
    error("Currently invalid dot shard in module load")

  first_shard, second_shard = cur_shard.args

  if isa(first_shard, Symbol)
    push!(cur_list, first_shard)
  elseif isa(first_shard, Expr)
    _expand_dot_var(cur_package, first_shard, cur_list)
  else
    error("Unable to determine what to do with dot shard: $cur_shard [1/2]")
  end

  if isa(second_shard, Symbol)
    push!(cur_list, second_shard)
  elseif isa(second_shard, QuoteNode)
    push!(cur_list, cur_package.eval(second_shard))
  else
    error("Unable to determine what to do with dot shard: $cur_shard [2/2]")
  end

  cur_list
end

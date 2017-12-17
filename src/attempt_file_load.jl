function attempt_file_load(cur_package::Module, cur_dict::Dict)

  for cur_shard in cur_dict["loaded_shards"]
    cur_package.eval(cur_shard)
  end

  loaded_indices = Array{Integer}(0)

  for (cur_index, cur_shard) in enumerate(cur_dict["unloaded_shards"])

    cur_eval = nothing

    try
      cur_eval = cur_package.eval(cur_shard)
    catch cur_error
      isa(cur_error, UndefVarError) || rethrow(cur_error)
      cur_dict["undef"] = cur_error.var

      break
    end

    cur_dict["undef"] = nothing

    if isa(cur_eval, Module)
      push!(loaded_indices, cur_index)
      continue
    end

    if macroexpand(cur_shard).head == :error
      cur_shard = clean_shard(cur_shard)
    else
      cur_shard = clean_shard(macroexpand(cur_shard))
    end

    ( cur_shard == nothing ) && ( cur_shard = :() )

    push!(loaded_indices, cur_index)

    push!(cur_dict["loaded_shards"], cur_shard)

  end

  deleteat!(cur_dict["unloaded_shards"], loaded_indices)

  return !isempty(loaded_indices)

end

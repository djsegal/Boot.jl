function attempt_file_load!(cur_package::Module, cur_dict::Dict)

  for cur_shard in cur_dict["loaded_shards"]
    cur_package.eval(cur_shard)
  end

  loaded_indices = Array{Integer}(0)

  for (cur_index, cur_shard) in enumerate(cur_dict["unloaded_shards"])

    cur_error, cur_time = attempt_shard_load!(
      cur_package, cur_dict, cur_shard
    )

    ( cur_error == nothing ) || break

    push!(loaded_indices, cur_index)

    push!(
      cur_dict["loaded_shards"],
      clean_shard(cur_package, cur_shard)
    )

  end

  deleteat!(cur_dict["unloaded_shards"], loaded_indices)

  return !isempty(loaded_indices)

end

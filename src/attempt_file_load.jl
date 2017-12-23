function attempt_file_load!(cur_package::Module, cur_info::FileInfo)

  for cur_shard in cur_info.loaded_shards
    isempty(cur_shard.args) && continue
    cur_package.eval(cur_shard)
  end

  loaded_indices = Array{Integer}(0)

  for (cur_index, cur_shard) in enumerate(cur_info.unloaded_shards)

    did_load = attempt_shard_load!(
      cur_package, cur_info, cur_shard
    )

    did_load || break

    push!(loaded_indices, cur_index)

    push!(
      cur_info.loaded_shards,
      clean_shard(cur_package, cur_shard)
    )

  end

  deleteat!(cur_info.unloaded_shards, loaded_indices)

  return !isempty(loaded_indices)

end

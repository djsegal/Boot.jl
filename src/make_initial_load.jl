function make_initial_load(cur_package::Module, all_files::AbstractArray)

  file_dicts = Array{Dict{AbstractString, Any}}(0)

  for cur_file in all_files

    cur_shards = parse_file(cur_file)

    cur_dict = Dict(
      "name" => cur_file,
      "undef" => nothing,
      "time" => 0.0,
      "loaded_shards" => Array{Expr}(0)
    )

    bad_index = 0

    for (cur_index, cur_shard) in enumerate(cur_shards)

      cur_error = attempt_shard_load!(
        cur_package, cur_dict, cur_shard
      )

      if cur_error != nothing
        bad_index = cur_index
        break
      end

      push!(cur_dict["loaded_shards"], cur_shard)

    end

    iszero(bad_index) && continue

    cur_dict["unloaded_shards"] = cur_shards[bad_index:end]

    for (cur_index, cur_shard) in enumerate(cur_dict["loaded_shards"])

      cur_dict["loaded_shards"][cur_index] =
        clean_shard(cur_package, cur_shard)

    end

    push!(file_dicts, cur_dict)

  end

  file_dicts

end

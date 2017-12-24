function make_initial_load(cur_package::Module, all_files::AbstractArray; verbose::Bool=false, is_test::Bool=false)

  cur_cabinet = FileCabinet()

  verbose && println("\ninitial load:\n")

  for cur_file in all_files

    verbose && print(cur_file * " ")

    cur_shards = parse_file(cur_file)

    cur_info = FileInfo(cur_file, cur_cabinet)

    bad_index = 0

    for (cur_index, cur_shard) in enumerate(cur_shards)

      did_load = attempt_shard_load!(
        cur_package, cur_info, cur_shard, is_test
      )

      if !did_load
        bad_index = cur_index
        break
      end

      push!(cur_info.loaded_shards, cur_shard)

    end

    verbose && println( iszero(bad_index) ? "✓" : "X" )

    iszero(bad_index) && continue

    cur_info.unloaded_shards = cur_shards[bad_index:end]

    for (cur_index, cur_shard) in enumerate(cur_info.loaded_shards)

      cur_info.loaded_shards[cur_index] =
        clean_shard(cur_package, cur_shard)

    end

    push!(cur_cabinet.file_infos, cur_info)

  end

  cur_cabinet

end

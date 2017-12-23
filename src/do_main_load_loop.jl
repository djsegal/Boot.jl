function do_main_load_loop!(cur_package::Module, file_infos::AbstractArray; is_sorted::Bool=false, verbose::Bool=false)

  verbose && println("\nmain load loop:\n")

  skip_undef = true

  loaded_files_count = 1

  while !iszero(loaded_files_count)

    verbose && println("-----")

    loaded_files_count = 0

    is_sorted || sort!(
      file_infos,
      by = ( cur_info -> cur_info.time )
    )

    delete_indices = Array{Integer}(0)

    for (cur_index, cur_info) in enumerate(file_infos)

      has_undef_var = (
        skip_undef &&
        ( cur_info.undef != nothing ) &&
        !isdefined(cur_package, cur_info.undef)
      )

      has_undef_var && continue

      verbose && print(cur_info.name * " ")

      did_load = attempt_file_load!(cur_package, cur_info)

      did_load && ( loaded_files_count += 1 )

      verbose && println( did_load ? "✓" : "X" )

      isempty(cur_info.unloaded_shards) &&
        push!(delete_indices, cur_index)

      ( loaded_files_count >= 3 ) && break

    end

    deleteat!(file_infos, delete_indices)

    iszero(length(file_infos)) && break

    if skip_undef
      iszero(loaded_files_count) || continue
    else
      iszero(loaded_files_count) && continue
    end

    skip_undef && ( loaded_files_count = 1 )

    skip_undef = !skip_undef

  end

end

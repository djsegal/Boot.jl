function do_main_load_loop!(cur_package::Module, file_dicts::AbstractArray; is_sorted::Bool=false, verbose::Bool=false)

  verbose && println("\nmain load loop:\n")

  loaded_files_count = 1

  while !iszero(loaded_files_count)

    verbose && println("-----")

    loaded_files_count = 0

    is_sorted || sort!(
      file_dicts,
      by = ( cur_dict -> cur_dict["time"] )
    )

    delete_indices = Array{Integer}(0)

    for (cur_index, cur_dict) in enumerate(file_dicts)

      has_undef_var = (
        ( cur_dict["undef"] != nothing ) &&
        !isdefined(cur_package, cur_dict["undef"])
      )

      has_undef_var && continue

      verbose && print(cur_dict["name"] * " ")

      did_load = attempt_file_load!(cur_package, cur_dict)

      did_load && ( loaded_files_count += 1 )

      verbose && println( did_load ? "✓" : "X" )

      isempty(cur_dict["unloaded_shards"]) &&
        push!(delete_indices, cur_index)

      ( loaded_files_count >= 3 ) && break

    end

    deleteat!(file_dicts, delete_indices)

  end

end

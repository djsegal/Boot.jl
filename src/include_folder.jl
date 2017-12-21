function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=true, except_for::AbstractArray=[])

  # allow loading folder by index file

  if isempty(except_for) && endswith(cur_folder,".jl")
    cur_file = cur_folder

    cur_folder = dirname(cur_file)
    except_for = [cur_file]
  end

  # make initial load

  all_files = get_all_files(cur_folder, except_for=except_for, is_sorted=is_sorted)

  file_dicts = make_initial_load(cur_package, all_files)

  # load all files

  loaded_files_count = 1

  while !iszero(loaded_files_count)

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

      attempt_file_load!(cur_package, cur_dict) &&
        ( loaded_files_count += 1 )

      isempty(cur_dict["unloaded_shards"]) &&
        push!(delete_indices, cur_index)

      ( loaded_files_count >= 3 ) && break

    end

    deleteat!(file_dicts, delete_indices)

  end

  # raise errors for undefined variables

  if !isempty(file_dicts)

    first_bad_file = first(file_dicts)

    load_invalid_file(cur_package, first_bad_file)

  end

end

function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=true, except_for::AbstractArray=[])

  if isempty(except_for) && endswith(cur_folder,".jl")
    cur_file = cur_folder

    cur_folder = dirname(cur_file)
    except_for = [cur_file]
  end

  all_files = get_all_files(cur_folder, is_sorted=is_sorted)

  all_files = map(abspath, all_files)

  except_for = map(abspath, except_for)

  filter!(
    cur_file -> !in(cur_file, except_for),
    all_files
  )

  unloaded_files = copy(all_files)

  loaded_files = []

  while length(unloaded_files) > 0

    new_file_count = 0

    for file in copy(unloaded_files)

      init_methods_list = get_package_methods(cur_package)

      try

        include(file)

        Revise.track(cur_package, file)

      catch

        cur_methods_list = get_package_methods(cur_package)

        corrupted_methods = setdiff(cur_methods_list, init_methods_list)

        purge_corrupted_data!(cur_package, corrupted_methods)

        continue

      end

      push!(loaded_files, file)

      new_file_count += 1

    end

    unloaded_files = setdiff(all_files, loaded_files)

    if new_file_count == 0
      bad_file = unloaded_files[1]

      println(bad_file)
      include(bad_file)
    end

  end

end

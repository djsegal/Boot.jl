function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=true, except_for::AbstractArray=[], verbose::Bool=false, is_test::Bool=false)

  # allow loading folder by index file

  if isempty(except_for) && endswith(cur_folder,".jl")
    cur_file = cur_folder

    cur_folder = dirname(cur_file)
    except_for = [cur_file]
  end

  # load all files

  all_files = get_all_files(cur_folder, except_for=except_for, is_sorted=is_sorted)

  file_dicts = make_initial_load(cur_package, all_files, verbose=verbose, is_test=is_test)

  is_test || do_main_load_loop!(cur_package, file_dicts, is_sorted=is_sorted, verbose=verbose)

  # raise errors for undefined variables

  isempty(file_dicts) || start_load_failure!(cur_package, file_dicts, verbose=verbose)


end

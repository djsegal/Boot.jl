function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=false, except_for::AbstractArray=[], verbose::Bool=false, is_test::Bool=false)

  Docs.initmeta(cur_package)

  # allow loading folder by index file

  if isempty(except_for) && endswith(cur_folder,".jl")
    cur_file = cur_folder

    cur_folder = dirname(cur_file)
    except_for = [cur_file]
  end

  # load all files

  all_files = get_all_files(cur_folder, except_for=except_for, is_sorted=true)

  cur_cabinet = make_initial_load(cur_package, all_files, verbose=verbose, is_test=is_test)

  is_test || do_main_load_loop!(cur_package, cur_cabinet, is_sorted=is_sorted, verbose=verbose)

  # raise errors for undefined variables

  isempty(cur_cabinet.file_infos) ||
    start_load_failure!(cur_package, cur_cabinet, verbose=verbose)

  # print verbose messages

  if verbose
    print_load_info(cur_cabinet)
    println("\ndone.\n")
  end

  # return the file cabinet

  cur_cabinet

end

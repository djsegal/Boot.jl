function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=true, except_for::AbstractArray=[])

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

        new_methods = setdiff(cur_methods_list, init_methods_list)

        for new_method in new_methods
          delete_method(new_method)
        end

        Docs.initmeta(cur_package)

        for new_method in new_methods

          new_method_name = new_method.name

          b = Docs.Binding(cur_package, new_method_name)
          m = get!(Docs.meta(cur_package), b, Docs.MultiDoc())

          cur_sig_string = string(new_method.sig)

          cur_sig_string = replace(cur_sig_string, "$(cur_package).#$(new_method_name)", "")

          cur_sig_string = replace(cur_sig_string, "{,", "{")

          cur_sig = cur_package.eval(parse(string(cur_sig_string)))

          cur_keys = collect(keys(m.docs))

          for cur_key in cur_keys
            ( cur_sig <: cur_key ) || continue

            delete!(m.docs, cur_key)
          end

        end

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

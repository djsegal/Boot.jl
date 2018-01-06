function start_load_failure!(cur_package::Module, cur_cabinet::FileCabinet; verbose::Bool=false)

  if verbose

    println("\ninvalid files:\n")

    for cur_info in cur_cabinet.file_infos

      println(cur_info.name * " - " * string(cur_info.undef))

    end

    println("-----")

  end

  cur_error = nothing

  for (cur_index, cur_info) in enumerate(cur_cabinet.file_infos)

    try
      load_invalid_file(cur_package, cur_info)
    catch tmp_error
      cur_error = tmp_error

      verbose || break
      ( cur_index == length(cur_cabinet.file_infos) ) && break

      showerror(STDERR, tmp_error)
      println("\n-----")
    end

  end

  rethrow(cur_error)

end

function start_load_failure!(cur_package::Module, cur_cabinet::FileCabinet; verbose::Bool=false)

  if verbose

    println("\ninvalid files:\n")

    for cur_info in cur_cabinet.file_infos

      println(cur_info.name * " - " * string(cur_info.undef))

    end

    println("-----")

  end

  first_bad_file = first(cur_cabinet.file_infos)

  load_invalid_file(cur_package, first_bad_file)

end

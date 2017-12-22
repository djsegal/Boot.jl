function start_load_failure!(cur_package::Module, file_dicts::AbstractArray; verbose::Bool=false)

  if verbose

    println("\ninvalid files:\n")

    for cur_file in file_dicts

      println(cur_file["name"] * " - " * string(cur_file["undef"]))

    end

    println("-----")

  end

  first_bad_file = first(file_dicts)

  load_invalid_file(cur_package, first_bad_file)

end

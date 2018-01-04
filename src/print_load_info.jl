function print_load_info(cur_cabinet::FileCabinet)

  println("\nCurrent load order:\n")

  for cur_file in cur_cabinet.load_order
    println(" + ", cur_file)
  end

  if !isempty(cur_cabinet.export_list)

    println("\nExported the following undefined variables:\n")

    for cur_export in cur_cabinet.export_list
      println(" + ", cur_export)
    end

  end

end

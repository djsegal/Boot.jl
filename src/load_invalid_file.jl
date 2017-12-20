function load_invalid_file(cur_package::Module, invalid_file::Dict)

  # read in file

  cur_file = invalid_file["name"]

  opened_file = open(cur_file)

  read_file = readstring(opened_file)

  seekstart(opened_file)

  # find shard in file

  for cur_shard in invalid_file["loaded_shards"]
    parse(opened_file)
  end

  beg_position = position(opened_file)

  iszero(beg_position) && ( beg_position = 1 )

  parse(opened_file)

  end_position = position(opened_file)

  close(opened_file)

  # build include string

  line_count = length(
    matchall(
      r"\n",
      read_file[1:beg_position-1]
    )
  )

  cur_string = "\n" ^ line_count

  cur_string *= read_file[beg_position:end_position]

  # make call to bad file

  cur_package.include_string(cur_string, cur_file)

end

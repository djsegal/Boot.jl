function parse_file(cur_file::AbstractString)

  file_shards = Array{Expr}(0)

  opened_file = open(cur_file)

  cur_expression = parse(opened_file)

  while cur_expression != nothing
    push!(file_shards, cur_expression)
    cur_expression = parse(opened_file)
  end

  close(opened_file)

  file_shards

end

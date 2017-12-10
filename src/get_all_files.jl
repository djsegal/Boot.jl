function get_all_files(cur_folder::AbstractString; is_sorted::Bool=true)
  nested_files = _get_nested_files(cur_folder)

  is_sorted ? sort!(nested_files) : shuffle!(nested_files)

  nested_files
end

function _get_nested_files(cur_item::AbstractString)
  nested_files = []

  if isfile(cur_item)
    endswith(cur_item, ".jl") &&
      push!(nested_files, cur_item)

    return nested_files
  end

  for sub_item in readdir(cur_item)
    startswith(sub_item, ".") && continue

    sub_nested_files = _get_nested_files("$cur_item/$sub_item")

    append!(nested_files, sub_nested_files)
  end

  return nested_files
end

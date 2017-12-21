function get_all_files(cur_folder::AbstractString; is_sorted::Bool=true, except_for::AbstractArray=[])
  nested_files = _get_nested_files(cur_folder)

  is_sorted ? sort!(nested_files) : shuffle!(nested_files)

  nested_files = _remove_unwanted_files(nested_files, except_for)

  nested_files
end

function _get_nested_files(cur_item::AbstractString)
  nested_files = Array{AbstractString}(0)

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

function _remove_unwanted_files(nested_files::AbstractArray, except_for::AbstractArray)
  nested_files = map(abspath, nested_files)

  except_for = map(abspath, except_for)

  filter!(
    cur_file -> !in(cur_file, except_for),
    nested_files
  )

  nested_files
end

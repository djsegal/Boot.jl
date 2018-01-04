function get_all_files(cur_folder::AbstractString; is_sorted::Bool=true, except_for::AbstractArray=[])
  cur_folder = abspath(cur_folder)

  _expand_except_for!(cur_folder, except_for)

  nested_files = _get_nested_files(cur_folder)

  is_sorted ? sort!(nested_files) : shuffle!(nested_files)

  nested_files = _remove_unwanted_files(nested_files, except_for)

  nested_files
end

function _expand_except_for!(cur_folder::AbstractString, except_for::AbstractArray)
  for (cur_index, cur_except) in enumerate(except_for)
    startswith(cur_except, "/") && continue

    except_for[cur_index] =
      joinpath(cur_folder, cur_except)
  end
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

    sub_nested_files = _get_nested_files(joinpath(cur_item, sub_item))

    append!(nested_files, sub_nested_files)
  end

  return nested_files
end

function _remove_unwanted_files(nested_files::AbstractArray, except_for::AbstractArray)
  except_files = filter(cur_except -> endswith(cur_except, ".jl"), except_for)

  except_folders = filter(cur_except -> endswith(cur_except, "/*"), except_for)

  except_folders = map(cur_except -> cur_except[1:end-2], except_folders)

  filter!(
    cur_file -> !in(cur_file, except_files),
    nested_files
  )

  filter!(
    cur_file -> !any(cur_except -> startswith(cur_file, cur_except), except_folders),
    nested_files
  )

  nested_files
end

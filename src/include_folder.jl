function include_folder(cur_package::Module, cur_folder::AbstractString="."; is_sorted::Bool=true, except_for::AbstractArray=[])

  # allow loading folder by index file

  if isempty(except_for) && endswith(cur_folder,".jl")
    cur_file = cur_folder

    cur_folder = dirname(cur_file)
    except_for = [cur_file]
  end

  # get list of all files to be loaded

  all_files = get_all_files(cur_folder, is_sorted=is_sorted)

  all_files = map(abspath, all_files)

  except_for = map(abspath, except_for)

  filter!(
    cur_file -> !in(cur_file, except_for),
    all_files
  )

  # build file expressions

  file_dicts = Array{Dict{AbstractString, Any}}(0)

  for cur_file in all_files
    cur_dict = Dict(
      "name" => cur_file,
      "unloaded_shards" => parse_file(cur_file),
      "loaded_shards" => Array{Expr}(0),
      "undef" => nothing
    )

    push!(file_dicts, cur_dict)
  end

  # load all files

  has_loaded_file = true

  while has_loaded_file

    has_loaded_file = false

    for cur_dict in shuffle(file_dicts)
      isempty(cur_dict["unloaded_shards"]) && continue

      has_undef_var = (
        ( cur_dict["undef"] != nothing ) &&
        !isdefined(cur_package, cur_dict["undef"])
      )

      has_undef_var && continue

      has_loaded_file = (
        attempt_file_load(cur_package, cur_dict) || has_loaded_file
      )
    end

  end

  # make sure all files were loaded

  for cur_dict in file_dicts
    isempty(cur_dict["unloaded_shards"]) && continue
    bad_shard = first(cur_dict["unloaded_shards"])

    # raise error through loading bad shard
    cur_package.eval(bad_shard)
  end

end

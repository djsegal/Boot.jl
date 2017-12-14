__precompile__()

module Boot

  using Revise
  using Compat

  include("flatten_array.jl")

  include("delete_method.jl")
  include("delete_docstring.jl")
  include("purge_corrupted_data.jl")

  include("strip_output_color.jl")

  include("get_all_files.jl")
  include("get_all_symbols.jl")
  include("get_package_methods.jl")
  include("attempt_file_load.jl")
  include("clean_shard.jl")

  include("include_folder.jl")
  include("parse_file.jl")

  export get_all_files
  export get_all_symbols
  export get_package_methods

  export include_folder
  export parse_file

end

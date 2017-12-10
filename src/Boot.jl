__precompile__()

module Boot

  using Revise
  using Compat

  include("flatten_array.jl")
  include("delete_method.jl")

  include("purge_corrupted_data.jl")
  include("strip_output_color.jl")

  include("get_all_files.jl")
  include("get_all_symbols.jl")
  include("get_package_methods.jl")

  include("include_folder.jl")

  export get_all_files
  export get_all_symbols
  export get_package_methods

  export include_folder

end

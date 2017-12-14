__precompile__()

module Boot

  using Revise
  using Compat

  include("strip_output_color.jl")

  include("get_all_symbols.jl")
  include("get_all_files.jl")

  include("attempt_file_load.jl")
  include("clean_shard.jl")

  include("include_folder.jl")
  include("parse_file.jl")

  export get_all_symbols
  export get_all_files

  export include_folder
  export parse_file

end

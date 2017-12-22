__precompile__()

module Boot

  using Compat

  include("check_module_node.jl")
  include("purge_corrupted_methods.jl")
  include("strip_output_color.jl")

  include("do_main_load_loop.jl")
  include("make_initial_load.jl")
  include("attempt_file_load.jl")

  include("start_load_failure.jl")
  include("load_invalid_file.jl")

  include("shard_list_constants.jl")
  include("attempt_shard_load.jl")
  include("clean_shard.jl")

  include("include_folder.jl")

  include("get_method_count.jl")
  include("get_all_files.jl")
  include("parse_file.jl")

  export include_folder

  export get_method_count
  export get_all_files
  export parse_file

end

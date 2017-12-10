module DependencyTree

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(DependencyTree, varargs...; kwargs...)

  include_folder(@__FILE__)

end

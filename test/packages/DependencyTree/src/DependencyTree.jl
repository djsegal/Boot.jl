module DependencyTree

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(DependencyTree, varargs...; kwargs...)

  cd("$(dirname(@__FILE__))") do
    include_folder(except_for=[@__FILE__])
  end

end

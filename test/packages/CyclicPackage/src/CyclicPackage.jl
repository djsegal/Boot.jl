module CyclicPackage

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(CyclicPackage, varargs...; kwargs...)

  include_folder(@__FILE__)

end

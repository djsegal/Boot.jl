module SimplePackage

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(SimplePackage, varargs...; kwargs...)

  include_folder(@__FILE__)

end

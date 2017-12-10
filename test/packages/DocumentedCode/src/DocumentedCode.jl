module DocumentedCode

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(DocumentedCode, varargs...; kwargs...)

  include_folder(@__FILE__)

end

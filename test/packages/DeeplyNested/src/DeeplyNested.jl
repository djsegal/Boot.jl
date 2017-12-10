module DeeplyNested

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(DeeplyNested, varargs...; kwargs...)

  include_folder(@__FILE__)

end

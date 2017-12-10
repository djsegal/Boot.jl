module DocumentedCode

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(DocumentedCode, varargs...; kwargs...)

  cd("$(dirname(@__FILE__))") do
    include_folder(except_for=[@__FILE__])
  end

end

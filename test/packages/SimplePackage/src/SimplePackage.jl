module SimplePackage

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(SimplePackage, varargs...; kwargs...)

  cd("$(dirname(@__FILE__))") do
    include_folder(except_for=[@__FILE__])
  end

end

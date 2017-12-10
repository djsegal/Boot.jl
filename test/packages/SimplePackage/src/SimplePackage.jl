module SimplePackage

  using Boot

  include_folder(cur_folder::AbstractString) =
    Boot.include_folder(SimplePackage, cur_folder)

  cd("$(dirname(@__FILE__))") do
    include_folder("a_folder")
  end

end

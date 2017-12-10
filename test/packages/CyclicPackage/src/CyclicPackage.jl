module CyclicPackage

  using Boot

  include_folder(cur_folder::AbstractString) =
    Boot.include_folder(CyclicPackage, cur_folder)

  cd("$(dirname(@__FILE__))") do
    include_folder("bad_folder")
  end

end

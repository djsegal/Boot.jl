module DependencyTree

  using Boot

  include_folder(cur_folder::AbstractString) =
    Boot.include_folder(DependencyTree, cur_folder)

  cd("$(dirname(@__FILE__))") do
    include_folder("heavy_folder")
  end

end

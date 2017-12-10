module DeeplyNested

  using Boot

  include_folder(cur_folder::AbstractString) =
    Boot.include_folder(DeeplyNested, cur_folder)

  cd("$(dirname(@__FILE__))") do
    include_folder("red_folder")
  end

end

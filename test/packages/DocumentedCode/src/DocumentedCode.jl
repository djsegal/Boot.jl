module DocumentedCode

  using Boot

  include_folder(cur_folder::AbstractString) =
    Boot.include_folder(DocumentedCode, cur_folder)

  cd("$(dirname(@__FILE__))") do
    include_folder("organized_folder")
  end

end

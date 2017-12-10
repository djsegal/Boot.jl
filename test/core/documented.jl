# documented package

err_data = @capture_err begin

  include("../packages/DocumentedCode/src/DocumentedCode.jl")

end

err_data = Boot.strip_output_color(err_data)

@test !contains(err_data, "WARNING: replacing docs for")

@test !contains(err_data, "WARNING: Method definition") &&
  !contains(err_data, "overwritten at")

@test isempty(strip(err_data))

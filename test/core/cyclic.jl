# cyclic package

out_data = @capture_out begin

  @test_throws LoadError include("../packages/CyclicPackage/src/CyclicPackage.jl")

end

@test contains(String(out_data), "bad_folder/thing_1.jl")

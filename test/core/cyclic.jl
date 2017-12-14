# cyclic package

test_error = nothing

try
  include("../packages/CyclicPackage/src/CyclicPackage.jl")
catch cur_error
  test_error = cur_error
end

@test isa(test_error.error, UndefVarError)
@test test_error.error.var == :Thing2

using Boot

using TestSetExtensions

using Base.Test

using Suppressor

@testset ExtendedTestSet "All Tests" begin

  include("core/simple.jl")
  include("core/nested.jl")

  include("core/dependency.jl")
  include("core/cyclic.jl")

  include("core/documented.jl")

end

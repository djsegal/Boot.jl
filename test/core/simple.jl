# simple package

include("../packages/SimplePackage/src/SimplePackage.jl")

@test isdefined(SimplePackage, :hello)

@test SimplePackage.hello() == "Hello, World!"


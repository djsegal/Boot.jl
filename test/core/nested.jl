# nested package

include("../packages/DeeplyNested/src/DeeplyNested.jl")

@test isdefined(DeeplyNested, :foo)

@test DeeplyNested.foo() == 123

@test isdefined(DeeplyNested, :bar)

@test DeeplyNested.bar() == 404

@test isdefined(DeeplyNested, :baz)

@test DeeplyNested.baz() == 999

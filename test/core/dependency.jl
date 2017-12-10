# dependency package

include("../packages/DependencyTree/src/DependencyTree.jl")

@test all(cur_char ->
  isdefined(
    DependencyTree,
    Symbol("Type$(cur_char)")
  ),
  'A':'Z'
)

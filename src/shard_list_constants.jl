const shard_type_union = Union{
  GlobalRef, Module, QuoteNode,
  Symbol, AbstractString,
  Integer, AbstractFloat,
  VersionNumber
}

const cur_return_nothing_shards = [
  :function, :abstract, :export,
  :const, :type, :stagedfunction
]

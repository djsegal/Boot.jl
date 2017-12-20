const shard_type_union = Union{
  GlobalRef, Module, QuoteNode,
  Symbol, AbstractString,
  Integer, AbstractFloat,
  VersionNumber
}

const cur_update_operators = [
  :(+=), :(-=), :(*=), :(/=), :(\=),
  :(÷=), :(%=), :(^=), :(&=), :(|=),
  :($=), :(>>>=), :(>>=), :(<<=)
]

const cur_nested_shards = [
  :->,
  :macrocall, :for,
  :block, :if,
  :call
]

const cur_return_self_shards = [
  :toplevel, :inbounds, :import,
  :return, :tuple, :where,
  :curly, :meta, :ref, :try, :line, :string,
  :(&&), :(||), :(<:),
  :(::), :(:), :(.), :(...)
]

const cur_return_nothing_shards = [
  :function, :abstract, :export, :using, :macro,
  :const, :type, :stagedfunction, :immutable
]

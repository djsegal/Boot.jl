mutable struct FileInfo
  name::AbstractString
  parent::AbstractArray{FileInfo}
  undef::Union{Any, Symbol}
  time::AbstractFloat
  loaded_shards::AbstractArray{Expr}
  unloaded_shards::AbstractArray{Expr}
end

FileInfo(name::AbstractString, parent::AbstractArray{FileInfo}) = FileInfo(
  name,
  parent,
  nothing,
  0.0,
  Array{Expr}(0),
  Array{Expr}(0)
)

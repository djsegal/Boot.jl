abstract type AbstractFileInfo end

# type declarations

mutable struct FileCabinet{ V <: Vector{<:AbstractFileInfo} }
  file_infos::V
end

mutable struct FileInfo <: AbstractFileInfo
  name::AbstractString
  parent::FileCabinet{Vector{FileInfo}}
  undef::Union{Any, Symbol}
  time::AbstractFloat
  loaded_shards::AbstractArray{Expr}
  unloaded_shards::AbstractArray{Expr}
end

# constructor functions

FileCabinet() = FileCabinet(
  FileInfo[]
)

FileInfo{U <: AbstractFileInfo}(name::AbstractString, parent::FileCabinet{Vector{U}}) =
  FileInfo(
    name,
    parent,
    nothing,
    0.0,
    Expr[],
    Expr[]
  )

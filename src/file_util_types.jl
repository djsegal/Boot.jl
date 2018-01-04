abstract type AbstractFileInfo end

# type declarations

mutable struct FileCabinet{ V <: Vector{<:AbstractFileInfo} }
  file_infos::V
  boot_module::Module
  export_list::Vector{Symbol}
  load_order::Vector{AbstractString}
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

function FileCabinet(cur_package::Module)
  cur_cabinet = FileCabinet(
    FileInfo[],
    cur_package.eval(parse("module BootDummy_$( camelize(string(Base.Random.uuid4())) ) end")),
    Symbol[],
    AbstractString[]
  )

  cur_cabinet
end

FileInfo{U <: AbstractFileInfo}(name::AbstractString, parent::FileCabinet{Vector{U}}) =
  FileInfo(
    name,
    parent,
    nothing,
    0.0,
    Expr[],
    Expr[]
  )

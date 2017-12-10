function flatten_array(cur_array::AbstractArray)

  while any( x -> typeof(x) <: AbstractArray , cur_array )

    cur_array = collect(
      Iterators.flatten(cur_array)
    )

  end

  return cur_array

end

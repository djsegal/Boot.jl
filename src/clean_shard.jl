const cur_update_operators = [
    :(+=), :(-=), :(*=), :(/=), :(\=),
    :(÷=), :(%=), :(^=), :(&=), :(|=),
    :($=), :(>>>=), :(>>=), :(<<=)
  ]

function clean_shard(cur_shard::shard_type_union)
  return cur_shard
end

function clean_shard(cur_shard::Expr)
  if cur_shard.head == :block || cur_shard.head == :for ||
      cur_shard.head == :if || cur_shard.head == :->
    for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
      ( cur_sub_shard == nothing ) && continue
      cur_shard.args[cur_index] = clean_shard(cur_sub_shard)
    end

    return cur_shard
  end

  if cur_shard.head == :call

    first_sub_shard = first(cur_shard.args)

    ( first_sub_shard == Base.Docs.doc! ) && ( return nothing )

    for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
      ( cur_sub_shard == nothing ) && continue
      cur_shard.args[cur_index] = clean_shard(cur_sub_shard)
    end

    return cur_shard

  end

  if cur_shard.head == :(=)

    first_sub_shard = first(cur_shard.args)

    isa(first_sub_shard, Symbol) && ( return cur_shard )
    var_type = first_sub_shard.head

    ( var_type == :ref ) && ( return cur_shard )
    ( var_type == :tuple ) && ( return cur_shard )

    ( var_type == :where ) && ( return nothing )
    ( var_type == :call ) && ( return nothing )

    error("Unable to determine what to do with :(=) shard: $cur_shard")

  end

  if cur_shard.head == :copyast
    for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
      cur_shard.args[cur_index] = QuoteNode(clean_shard(cur_package.eval(cur_sub_shard)))
    end

    return cur_shard
  end

  if any(x -> x == cur_shard.head, cur_update_operators)
    return cur_shard
  end

  if any(x -> x == cur_shard.head, cur_return_self_shards)
    return cur_shard
  end

  if any(x -> x == cur_shard.head, cur_return_nothing_shards)
    return nothing
  end

  error("Unable to determine what to do with node of type: $(string(cur_shard.head))")

  cur_shard
end

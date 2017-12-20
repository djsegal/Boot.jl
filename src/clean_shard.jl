function clean_shard(cur_package::Module, cur_shard::Expr)
  expanded_shard = macroexpand(cur_shard)

  if expanded_shard.head != :error
    cur_shard = _clean_shard(cur_package, expanded_shard)
  else
    cur_shard = _clean_shard(cur_package, cur_shard)
  end

  ( cur_shard == nothing ) && ( cur_shard = :() )

  cur_shard
end

function _clean_shard(cur_package::Module, cur_shard::shard_type_union)
  return cur_shard
end

function _clean_shard(cur_package::Module, cur_shard::Expr)

  if cur_shard.head == :call

    first_sub_shard = first(cur_shard.args)

    ( first_sub_shard == Base.Docs.doc! ) && ( return nothing )

  end

  if any(x -> x == cur_shard.head, cur_nested_shards)
    for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
      ( cur_sub_shard == nothing ) && continue
      cur_shard.args[cur_index] = _clean_shard(cur_package, cur_sub_shard)
    end

    return cur_shard
  end

  if any(x -> x == cur_shard.head, cur_update_operators)
    return cur_shard
  end

  if cur_shard.head == :(=)

    first_sub_shard = first(cur_shard.args)

    isa(first_sub_shard, Symbol) && ( return cur_shard )
    var_type = first_sub_shard.head

    ( var_type == :ref ) && ( return cur_shard )
    ( var_type == :tuple ) && ( return cur_shard )
    ( var_type == :curly ) && ( return cur_shard )

    ( var_type == :where ) && ( return nothing )
    ( var_type == :call ) && ( return nothing )

    error("Unable to determine what to do with :(=) shard: $cur_shard (of type $var_type)")

  end

  if cur_shard.head == :copyast
    for (cur_index, cur_sub_shard) in enumerate(cur_shard.args)
      cur_shard.args[cur_index] = QuoteNode(_clean_shard(cur_package, cur_package.eval(cur_sub_shard)))
    end

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
